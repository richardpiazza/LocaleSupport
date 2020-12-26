import Foundation
import PerfectSQLite
import StatementSQLite

public class SQLiteDatabase: Database {
    
    public enum Error: Swift.Error {
        case statement(action: String, statement: String, error: Swift.Error)
        case expressionID(id: Expression.ID)
        case expressionNamed(name: String)
        case translationID(id: Translation.ID)
    }
    
    private let db: SQLite
    
    public init(path: String) throws {
        db = try SQLite(path)
        try createSchema()
    }
    
    deinit {
        db.close()
    }
    
    private func createSchema() throws {
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
    
    public func expressions(having language: LanguageCode, region: RegionCode?) throws -> [Expression] {
        var expressions: [Expression] = []

        let statement = SQLiteStatement.selectExpressionsWith(languageCode: language, regionCode: region).render()
        
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
                    expression.translations = try translations(for: expression.id, language: language, region: region)
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
    
    public func translations(for expressionID: Expression.ID, language: LanguageCode?, region: RegionCode?) throws -> [Translation] {
        var translations: [Translation] = []
        
        let statement = SQLiteStatement.selectTranslationsFor(expressionID, languageCode: language, regionCode: region).render()
        
        do {
            try db.forEachRow(
                statement: statement,
                handleRow: { (statement, index) in
                    translations.append(statement.translation)
                }
            )
        } catch {
            throw Error.statement(action: "Query Translations", statement: statement, error: error)
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
            let translation = Translation(id: -1, expressionID: id, language: $0.language, region: $0.region, value: $0.value)
            try insertTranslation(translation)
        }
        
        return id
    }
    
    @discardableResult
    public func insertTranslation(_ translation: Translation) throws -> Translation.ID {
        let existing = try self.translations(for: translation.expressionID, language: translation.languageCode, region: translation.regionCode)
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
            region: optional(position: 3),
            value: columnText(position: 4)
        )
    }
}
