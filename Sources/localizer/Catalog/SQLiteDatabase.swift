import Foundation
import PerfectSQLite

public class SQLiteDatabase: Database {
    
    private let db: SQLite
    
    public init(path: String) throws {
        db = try SQLite(path)
        try createSchema()
    }
    
    deinit {
        db.close()
    }
    
    private func createSchema() throws {
        try db.execute(
            statement: """
            CREATE TABLE IF NOT EXISTS "\(Expression.table)" (
                "\(Expression.CodingKeys.id.rawValue)" INTEGER NOT NULL UNIQUE,
                "\(Expression.CodingKeys.name.rawValue)" TEXT NOT NULL,
                "\(Expression.CodingKeys.defaultLanguage.rawValue)" TEXT NOT NULL,
                "\(Expression.CodingKeys.comment.rawValue)" TEXT,
                "\(Expression.CodingKeys.feature.rawValue)" TEXT,
                PRIMARY KEY("\(Expression.CodingKeys.id.rawValue)" AUTOINCREMENT)
            );
            """
        )
        
        try db.execute(
            statement: """
            CREATE TABLE IF NOT EXISTS "\(Translation.table)" (
                "\(Translation.CodingKeys.id.rawValue)" INTEGER NOT NULL UNIQUE,
                "\(Translation.CodingKeys.expressionID.rawValue)" INTEGER NOT NULL,
                "\(Translation.CodingKeys.language.rawValue)" TEXT NOT NULL,
                "\(Translation.CodingKeys.region.rawValue)" TEXT,
                "\(Translation.CodingKeys.value.rawValue)" TEXT NOT NULL,
                PRIMARY KEY("\(Translation.CodingKeys.id.rawValue)" AUTOINCREMENT),
                FOREIGN KEY("\(Translation.CodingKeys.expressionID.rawValue)") REFERENCES \(String(describing: Expression.self).lowercased())(\(Expression.CodingKeys.id.rawValue))
            );
            """
        )
    }
    
    private let selectFromExpression = """
    SELECT
    "\(Expression.CodingKeys.id.rawValue)",
    "\(Expression.CodingKeys.name.rawValue)",
    "\(Expression.CodingKeys.defaultLanguage.rawValue)",
    "\(Expression.CodingKeys.comment.rawValue)",
    "\(Expression.CodingKeys.feature.rawValue)"
    FROM
    "\(Expression.table)"
    """
    
    private let selectFromTranslation = """
    SELECT
    "\(Translation.CodingKeys.id.rawValue)",
    "\(Translation.CodingKeys.expressionID.rawValue)",
    "\(Translation.CodingKeys.language.rawValue)",
    "\(Translation.CodingKeys.region.rawValue)",
    "\(Translation.CodingKeys.value.rawValue)"
    FROM
    "\(Translation.table)"
    """
    
    private let expressionJoinTranslation = """
    JOIN "\(Translation.table)"
        ON "\(Expression.table)"."\(Expression.CodingKeys.id.rawValue)" = "\(Translation.table)"."\(Translation.CodingKeys.expressionID.rawValue)"
    """
    
    public func expressions(includeTranslations: Bool) -> [Expression] {
        var expressions: [Expression] = []
        
        do {
            try db.forEachRow(
                statement: "\(selectFromExpression);",
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
        
        let clause: String
        let binding: (SQLiteStmt) throws -> ()
        
        switch region {
        case .some(let code):
            clause = """
            "\(Translation.table)"."\(Translation.CodingKeys.language.rawValue)" = :1
                AND "\(Translation.table)"."\(Translation.CodingKeys.region.rawValue)" = :2
            """
            binding = {
                try $0.bind(position: 1, language.rawValue)
                try $0.bind(position: 2, code.rawValue)
            }
        case .none:
            clause = """
            "\(Translation.table)"."\(Translation.CodingKeys.language.rawValue)" = :1
            """
            binding = { try $0.bind(position: 1, language.rawValue) }
        }
        
        do {
            try db.forEachRow(
                statement: """
                \(selectFromExpression)
                \(expressionJoinTranslation)
                WHERE
                \(clause);
                """,
                doBindings: binding,
                handleRow: { (statement, index) in
                    var expression = Expression(
                        id: statement.identity(position: 0),
                        name: statement.columnText(position: 1),
                        defaultLanguage: .en,
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
                statement: "\(selectFromTranslation);",
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
                statement: """
                \(selectFromTranslation)
                WHERE
                "\(Translation.CodingKeys.id.rawValue)" = :1
                LIMIT 1;
                """,
                doBindings: { (statement) in
                    try statement.bind(position: 1, id)
                },
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
        
        let clause: String
        let binding: (SQLiteStmt) throws -> ()
        
        switch (language, region) {
        case (.some(let languageCode), .some(let regionCode)):
            clause = """
            "\(Translation.CodingKeys.id.rawValue)" = :1
                AND "\(Translation.CodingKeys.language.rawValue)" = :2
                AND "\(Translation.CodingKeys.region.rawValue)" = :3
            """
            binding = {
                try $0.bind(position: 1, expressionID)
                try $0.bind(position: 2, languageCode.rawValue)
                try $0.bind(position: 3, regionCode.rawValue)
            }
        case (.some(let languageCode), .none):
            clause = """
            "\(Translation.CodingKeys.id.rawValue)" = :1
                AND "\(Translation.CodingKeys.language.rawValue)" = :2
            """
            binding = {
                try $0.bind(position: 1, expressionID)
                try $0.bind(position: 2, languageCode.rawValue)
            }
        case (.none, .some(let regionCode)):
            clause = """
            "\(Translation.CodingKeys.id.rawValue)" = :1
                AND "\(Translation.CodingKeys.region.rawValue)" = :2
            """
            binding = {
                try $0.bind(position: 1, expressionID)
                try $0.bind(position: 2, regionCode.rawValue)
            }
        default:
            clause = """
            "\(Translation.CodingKeys.id.rawValue)" = :1
            """
            binding = {
                try $0.bind(position: 1, expressionID)
            }
        }
        
        do {
            try db.forEachRow(
                statement: """
                \(selectFromTranslation)
                WHERE
                \(clause);
                """,
                doBindings: binding,
                handleRow: { (statement, index) in
                    translations.append(statement.translation)
                }
            )
        } catch {
            print(error)
        }
        
        return translations
    }
    
    public func insert(_ expression: Expression) throws {
        var id: Expression.ID = expression.id
        
        switch self.expression(named: expression.name) {
        case .some(let existing):
            id = existing.id
            // UPDATE?
        case .none:
            try db.execute(
                statement: """
                INSERT INTO "\(Expression.table)" (
                    "\(Expression.CodingKeys.name.rawValue)",
                    "\(Expression.CodingKeys.defaultLanguage.rawValue)",
                    \(Expression.CodingKeys.comment.rawValue),
                    \(Expression.CodingKeys.feature.rawValue)
                ) VALUES (:1, :2, :3, :4);
                """) { (statement) in
                try statement.bind(position: 1, expression.name)
                try statement.bind(position: 2, expression.defaultLanguage.rawValue)
                if let comment = expression.comment, !comment.isEmpty {
                    try statement.bind(position: 3, comment)
                } else {
                    try statement.bindNull(position: 3)
                }
                if let feature = expression.feature, !feature.isEmpty {
                    try statement.bind(position: 4, feature)
                } else {
                    try statement.bindNull(position: 4)
                }
            }
            
            id = db.lastInsertRowID()
        }
        
        try expression.translations.forEach {
            let translation = Translation(id: -1, expressionID: id, language: $0.language, region: $0.region, value: $0.value)
            try insert(translation)
        }
    }
    
    public func insert(_ translation: Translation) throws {
        let existing = self.translations(for: translation.expressionID, language: translation.language, region: translation.region)
        guard existing.isEmpty else {
            return
        }
        
        try db.execute(
            statement: """
            INSERT INTO "\(Translation.table)" (
                "\(Translation.CodingKeys.expressionID.rawValue)",
                "\(Translation.CodingKeys.language.rawValue)",
                "\(Translation.CodingKeys.region.rawValue)",
                "\(Translation.CodingKeys.value.rawValue)"
            ) VALUES (:1, :2, :3, :4);
            """, doBindings: { (statement) in
                try statement.bind(position: 1, translation.expressionID)
                try statement.bind(position: 2, translation.language.rawValue)
                if let region = translation.region {
                    try statement.bind(position: 3, region.rawValue)
                } else {
                    try statement.bindNull(position: 3)
                }
                try statement.bind(position: 4, translation.value)
            }
        )
    }
}

private extension SQLiteDatabase {
    enum ExpressionQuery {
        case id(_ id: Expression.ID)
        case name(_ name: String)
    }
    
    func expression(query: ExpressionQuery) -> Expression? {
        var expression: Expression?
        
        let field: String
        let binding: (SQLiteStmt) throws -> ()
        
        switch query {
        case .id(let id):
            field = Expression.CodingKeys.id.rawValue
            binding = { try $0.bind(position: 1, id) }
        case .name(let name):
            field = Expression.CodingKeys.name.rawValue
            binding = { try $0.bind(position: 1, name) }
        }
        
        do {
            try db.forEachRow(
                statement: """
                \(selectFromExpression)
                WHERE "\(field)" = :1
                LIMIT 1;
                """,
                doBindings: binding,
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
            defaultLanguage: languageCode(position: 2),
            comment: optional(position: 3),
            feature: optional(position: 4),
            translations: []
        )
    }
    
    var translation: Translation {
        Translation(
            id: identity(position: 0),
            expressionID: identity(position: 1),
            language: languageCode(position: 2),
            region: optional(position: 3),
            value: columnText(position: 4)
        )
    }
}

private extension Expression {
    static let table = String(describing: Expression.self).lowercased()
}

private extension Translation {
    static let table = String(describing: Translation.self).lowercased()
}
