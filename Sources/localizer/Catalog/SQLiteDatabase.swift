import Foundation
import PerfectSQLite
import StatementSQLite
import LocaleSupport

public class SQLiteDatabase: Database {
    
    public enum Error: Swift.Error {
        case statement(action: String, statement: String, error: Swift.Error)
        case expressionID(id: Expression.ID)
        case expressionNamed(name: String)
        case translationID(id: Translation.ID)
        case migration(from: Int, to: Int)
    }
    
    private enum SchemaVersion: Int {
        case undefined = 0
        case v1 = 1
        case v2 = 2
        
        static var current: Self { .v2 }
    }
    
    private struct MigrationStep {
        let source: SchemaVersion
        let destination: SchemaVersion
    }
    
    private let db: SQLite
    
    private var schemaVersion: SchemaVersion {
        var schemaVersion: SchemaVersion = .undefined
        
        let sql = "PRAGMA user_version;"
        
        do {
            try db.forEachRow(
                statement: sql,
                handleRow: { (statement, index) in
                    if let version = SchemaVersion(rawValue: statement.columnInt(position: 0)) {
                        schemaVersion = version
                    }
                })
        } catch {
            print(error)
        }
        
        return schemaVersion
    }
    
    private var tableNames: [String] {
        var names: [String] = []
        
        let sql = "SELECT name FROM sqlite_master WHERE type='table';"
        
        do {
            try db.forEachRow(statement: sql, handleRow: { (statement, index) in
                names.append(statement.columnText(position: 0))
            })
        } catch {
            print(error)
        }
        
        return names
    }
    
    public init(path: String) throws {
        db = try SQLite(path)
        
        let schemaVersion = self.schemaVersion
        if schemaVersion != .current {
            try migrateSchema(from: schemaVersion, to: .current)
        }
    }
    
    deinit {
        db.close()
    }
    
    private func setSchemaVersion(_ version: SchemaVersion) throws {
        let sql = "PRAGMA user_version = \(version.rawValue);"
        try db.execute(statement: sql)
    }
    
    private func createSchema(_ version: SchemaVersion) throws {
        var statement = SQLiteStatement.createExpression.render()
        do {
            try db.execute(statement: statement)
        } catch {
            throw Error.statement(action: "Create Expression Table", statement: statement, error: error)
        }
        
        statement = SQLiteStatement.createTranslation.render()
        do {
            try db.execute(statement: statement)
        } catch {
            throw Error.statement(action: "Create Translation Table", statement: statement, error: error)
        }
        
        try setSchemaVersion(version)
    }
    
    private func migrateSchema(from: SchemaVersion, to: SchemaVersion) throws {
        guard to.rawValue != from.rawValue else {
            // Migration complete
            return
        }
        
        guard to.rawValue > from.rawValue else {
            // Invalid migration direction
            throw Error.migration(from: from.rawValue, to: to.rawValue)
        }
        
        switch (from) {
        case .undefined:
            let names = tableNames
            if names.contains(Expression.schema.name) {
                try setSchemaVersion(.v1)
            } else {
                try createSchema(.current)
            }
        case .v1:
            print("Migrating schema from '\(from.rawValue)' to '\(to.rawValue)'.")
            let sql = SQLiteStatement.translationTable_addScriptCode.render()
            try db.execute(statement: sql)
            try setSchemaVersion(.v2)
        case .v2:
            break
        }
        
        guard let next = SchemaVersion(rawValue: from.rawValue + 1) else {
            throw Error.migration(from: from.rawValue, to: from.rawValue + 1)
        }
        
        try migrateSchema(from: next, to: to)
    }
    
    public func expressions(includeTranslations: Bool) throws -> [Expression] {
        var expressions: [Expression] = []
        
        let statement = SQLiteStatement.selectAllFromExpression.render()
        
        do {
            try db.forEachRow(
                statement: statement,
                handleRow: { (statement, index) in
                    var expression = statement.expression
                    if includeTranslations {
                        expression.translations = try translations(for: expression.id)
                    }
                    expressions.append(expression)
                }
            )
        } catch {
            throw Error.statement(action: "Select All Expressions", statement: statement, error: error)
        }
        
        return expressions
    }
    
    public func expression(_ id: Expression.ID) throws -> Expression {
        return try expression(query: .id(id))
    }
    
    public func expression(named name: String) throws -> Expression {
        return try expression(query: .name(name))
    }
    
    public func expressions(having language: LanguageCode, script: ScriptCode?, region: RegionCode?, fallback: Bool) throws -> [Expression] {
        var expressions: [Expression] = []

        let statement: String
        if fallback {
            statement = SQLiteStatement.selectAllFromExpression.render()
        } else {
            statement = SQLiteStatement.selectExpressionsWith(languageCode: language, scriptCode: script, regionCode: region).render()
        }
        
        do {
            try db.forEachRow(
                statement: statement,
                handleRow: { (statement, index) in
                    var expression = Expression(
                        id: statement.identity(position: 0),
                        name: statement.columnText(position: 1),
                        languageCode: .en,
                        comment: statement.optional(position: 2),
                        feature: nil,
                        translations: []
                    )
                    if let translations = try? self.translations(for: expression.id, language: language, script: script, region: region), !translations.isEmpty {
                        expression.translations = translations
                    } else {
                        expression.translations = try translations(for: expression.id, language: language, script: nil, region: nil)
                    }
                    expressions.append(expression)
                }
            )
        } catch {
            throw Error.statement(action: "Query Expressions", statement: statement, error: error)
        }
        
        return expressions
    }
    
    public func translations() throws -> [Translation] {
        var translations: [Translation] = []
        
        let statement = SQLiteStatement.selectAllFromTranslation.render()
        
        do {
            try db.forEachRow(
                statement: statement,
                handleRow: { (statement, index) in
                    translations.append(statement.translation)
                }
            )
        } catch {
            throw Error.statement(action: "Select All Translations", statement: statement, error: error)
        }
        
        return translations
    }
    
    public func translation(_ id: Translation.ID) throws -> Translation {
        var translation: Translation?
        
        let statement = SQLiteStatement.selectTranslation(id).render()
        
        do {
            try db.forEachRow(
                statement: statement,
                handleRow: { (statement, index) in
                    translation = statement.translation
                }
            )
        } catch {
            throw Error.statement(action: "Query Translation", statement: statement, error: error)
        }
        
        guard let found = translation else {
            throw Error.translationID(id: id)
        }
        
        return found
    }
    
    public func translations(for expressionID: Expression.ID, language: LanguageCode?, script: ScriptCode?, region: RegionCode?) throws -> [Translation] {
        var translations: [Translation] = []
        
        let statement = SQLiteStatement.selectTranslationsFor(expressionID, languageCode: language, scriptCode: script, regionCode: region)
        let sql = statement.render()
        
        do {
            try db.forEachRow(
                statement: sql,
                handleRow: { (statement, index) in
                    translations.append(statement.translation)
                }
            )
        } catch {
            throw Error.statement(action: "Query Translations", statement: sql, error: error)
        }
        
        return translations
    }
    
    @discardableResult
    public func insertExpression(_ expression: Expression) throws -> Expression.ID {
        var id: Expression.ID = expression.id
        
        let found = try? self.expression(named: expression.name)
        
        switch found {
        case .some(let existing):
            id = existing.id
            // UPDATE?
        case .none:
            let statement = SQLiteStatement.insertExpression(expression).render()
            do {
                try db.execute(statement: statement)
            } catch {
                throw Error.statement(action: "Insert Expression", statement: statement, error: error)
            }
            id = db.lastInsertRowID()
        }
        
        try expression.translations.forEach {
            let translation = Translation(id: -1, expressionID: id, language: $0.language, script: $0.script, region: $0.region, value: $0.value)
            try insertTranslation(translation)
        }
        
        return id
    }
    
    @discardableResult
    public func insertTranslation(_ translation: Translation) throws -> Translation.ID {
        let existing = try self.translations(for: translation.expressionID, language: translation.languageCode, script: translation.scriptCode, region: translation.regionCode)
        guard existing.isEmpty else {
            return -1
        }
        
        let statement = SQLiteStatement.insertTranslation(translation).render()
        do {
            try db.execute(statement: statement)
        } catch {
            throw Error.statement(action: "Insert Translation", statement: statement, error: error)
        }
        return db.lastInsertRowID()
    }
    
    public func updateExpression(_ id: Expression.ID, _ update: Expression.Update) throws {
        try db.execute(statement: SQLiteStatement.updateExpression(id, update).render())
    }
    
    public func updateTranslation(_ id: Translation.ID, _ update: Translation.Update) throws {
        try db.execute(statement: SQLiteStatement.updateTranslation(id, update).render())
    }
    
    public func deleteExpression(_ id: Expression.ID) throws {
        let translations = try self.translations(for: id)
        try translations.forEach {
            try deleteTranslation($0.id)
        }
        
        try db.execute(statement: SQLiteStatement.deleteExpression(id).render())
    }
    
    public func deleteTranslation(_ id: Translation.ID) throws {
        try db.execute(statement: SQLiteStatement.deleteTranslation(id).render())
    }
}

private extension SQLiteDatabase {
    func expression(query: Expression.Query) throws -> Expression {
        var expression: Expression?
        
        let statement = SQLiteStatement.selectExpression(query).render()
        
        do {
            try db.forEachRow(
                statement: statement,
                handleRow: { (statement, index) in
                    expression = statement.expression
                }
            )
        } catch {
            throw Error.statement(action: "Query Expression", statement: statement, error: error)
        }
        
        guard let found = expression else {
            switch query {
            case .id(let id):
                throw Error.expressionID(id: id)
            case .name(let name):
                throw Error.expressionNamed(name: name)
            }
        }
        
        return found
    }
}

private extension SQLiteStmt {
    func optional<T>(position: Int) -> T? {
        guard !isNull(position: position) else {
            return nil
        }
        
        switch T.self {
        case is String.Type:
            return (columnText(position: position) as! T)
        case is ScriptCode.Type:
            return (ScriptCode(rawValue: columnText(position: position)) as! T)
        case is RegionCode.Type:
            return (RegionCode(rawValue: columnText(position: position)) as! T)
        default:
            return nil
        }
    }
    
    func identity(position: Int) -> Int {
        return columnInt(position: position)
    }
    
    func languageCode(position: Int) -> LanguageCode {
        return LanguageCode(rawValue: columnText(position: position)) ?? .default
    }
    
    func scriptCode(position: Int) -> ScriptCode? {
        guard !isNull(position: position) else {
            return nil
        }
        
        return ScriptCode(rawValue: columnText(position: position))
    }
    
    func regionCode(position: Int) -> RegionCode? {
        guard !isNull(position: position) else {
            return nil
        }
        
        return RegionCode(rawValue: columnText(position: position))
    }
    
    var expression: Expression {
        Expression(
            id: identity(position: 0),
            name: columnText(position: 1),
            languageCode: languageCode(position: 2),
            comment: optional(position: 3),
            feature: optional(position: 4),
            translations: []
        )
    }
    
    var translation: Translation {
        Translation(
            id: identity(position: 0),
            expressionID: identity(position: 1),
            language: languageCode(position: 2).rawValue,
            script: optional(position: 5),
            region: optional(position: 3),
            value: columnText(position: 4)
        )
    }
}
