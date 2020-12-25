import Foundation
import PerfectSQLite
import StatementSQLite

public class SQLiteDatabase: Database {
    
    public enum Error: Swift.Error {
        case expressionID(id: Expression.ID)
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
        try db.execute(statement: SQLiteStatement.createExpression.render())
        try db.execute(statement: SQLiteStatement.createTranslation.render())
    }
    
    public func expressions(includeTranslations: Bool) -> [Expression] {
        var expressions: [Expression] = []
        
        do {
            try db.forEachRow(
                statement: SQLiteStatement.selectAllFromExpression.render(),
                handleRow: { (statement, index) in
                    var expression = statement.expression
                    if includeTranslations {
                        expression.translations = translations(for: expression.id)
                    }
                    expressions.append(expression)
                }
            )
        } catch {
            print(error)
        }
        
        return expressions
    }
    
    public func expression(_ id: Expression.ID) -> Expression? {
        return expression(query: .id(id))
    }
    
    public func expression(named name: String) -> Expression? {
        return expression(query: .name(name))
    }
    
    public func expressions(having language: LanguageCode, region: RegionCode?) -> [Expression] {
        var expressions: [Expression] = []

        do {
            try db.forEachRow(
                statement: SQLiteStatement.selectExpressionsWith(languageCode: language, regionCode: region).render(),
                handleRow: { (statement, index) in
                    var expression = Expression(
                        id: statement.identity(position: 0),
                        name: statement.columnText(position: 1),
                        languageCode: .en,
                        comment: statement.optional(position: 2),
                        feature: nil,
                        translations: []
                    )
                    expression.translations = translations(for: expression.id, language: language, region: region)
                    expressions.append(expression)
                }
            )
        } catch {
            print(error)
        }
        
        return expressions
    }
    
    public func translations() -> [Translation] {
        var translations: [Translation] = []
        
        do {
            try db.forEachRow(
                statement: SQLiteStatement.selectAllFromTranslation.render(),
                handleRow: { (statement, index) in
                    translations.append(statement.translation)
                }
            )
        } catch {
            print(error)
        }
        
        return translations
    }
    
    public func translation(_ id: Translation.ID) -> Translation? {
        var translation: Translation?
        
        do {
            try db.forEachRow(
                statement: SQLiteStatement.selectTranslation(id).render(),
                handleRow: { (statement, index) in
                    translation = statement.translation
                }
            )
        } catch {
            print(error)
        }
        
        return translation
    }
    
    public func translations(for expressionID: Expression.ID, language: LanguageCode?, region: RegionCode?) -> [Translation] {
        var translations: [Translation] = []
        
        do {
            try db.forEachRow(
                statement: SQLiteStatement.selectTranslationsFor(expressionID, languageCode: language, regionCode: region).render(),
                handleRow: { (statement, index) in
                    translations.append(statement.translation)
                }
            )
        } catch {
            print(error)
        }
        
        return translations
    }
    
    @discardableResult
    public func insertExpression(_ expression: Expression) throws -> Expression.ID {
        var id: Expression.ID = expression.id
        
        switch self.expression(named: expression.name) {
        case .some(let existing):
            id = existing.id
            // UPDATE?
        case .none:
            let statement = SQLiteStatement.insertExpression(expression).render()
            print("""
            =====
            \(statement)
            =====
            """)
            try db.execute(statement: statement)
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
        let existing = self.translations(for: translation.expressionID, language: translation.languageCode, region: translation.regionCode)
        guard existing.isEmpty else {
            return -1
        }
        
        let statement = SQLiteStatement.insertTranslation(translation).render()
        print("""
        =====
        \(statement)
        =====
        """)
        try db.execute(statement: statement)
        return db.lastInsertRowID()
    }
    
    public func updateExpression(_ id: Expression.ID, _ update: Expression.Update) throws {
        try db.execute(statement: SQLiteStatement.updateExpression(id, update).render())
    }
    
    public func updateTranslation(_ id: Translation.ID, _ update: Translation.Update) throws {
        try db.execute(statement: SQLiteStatement.updateTranslation(id, update).render())
    }
    
    public func deleteExpression(_ id: Expression.ID) throws {
        let translations = self.translations(for: id)
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
    func expression(query: Expression.Query) -> Expression? {
        var expression: Expression?
        
        do {
            try db.forEachRow(
                statement: SQLiteStatement.selectExpression(query).render(),
                handleRow: { (statement, index) in
                    expression = statement.expression
                }
            )
        } catch {
            print(error)
        }
        
        return expression
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
