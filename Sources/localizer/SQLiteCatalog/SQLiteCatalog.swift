import Foundation
import LocaleSupport
import TranslationCatalog
import PerfectSQLite

public class SQLiteCatalog: TranslationCatalog.Catalog {
    
    public enum DeleteEntity: CatalogAction {
        case nothing
        case cascade
    }
    
    public enum InsertEntity: CatalogAction {
        case nothing
        case cascade
        case foreignKey(Int)
    }
    
    public enum ExpressionUpdate: CatalogAction {
        case key(String)
        case name(String)
        case defaultLanguage(LanguageCode)
        case context(String?)
        case feature(String?)
    }
    
    public enum TranslationUpdate: CatalogAction {
        case language(LanguageCode)
        case script(ScriptCode?)
        case region(RegionCode?)
        case value(String)
    }
    
    // TODO: Split into entity queries?
    public enum Query: CatalogQuery {
        case name(String)
        case expression(LanguageCode, ScriptCode?, RegionCode?)
        case translation(Expression.ID, LanguageCode, ScriptCode?, RegionCode?)
    }
    
    public enum Error: Swift.Error {
        case invalidAction(CatalogAction)
        case invalidQuery(CatalogQuery)
        case invalidProjectID(Project.ID)
        case invalidExpressionID(Expression.ID)
        case existingExpressionWithID(Expression.ID)
        case invalidTranslationID(TranslationCatalog.Translation.ID)
        case existingTranslationWithID(TranslationCatalog.Translation.ID)
        case unhandledConversion
    }
    
    private let db: SQLite
    
    public init() throws {
        db = try SQLite(schema: .current)
    }
    
    deinit {
        db.close()
    }
    
    public func projects() throws -> [Project] {
        preconditionFailure("Not Implemented")
    }
    
    public func project(_ id: Project.ID) throws -> Project {
        preconditionFailure("Not Implemented")
    }
    
    public func project(matching query: CatalogQuery) throws -> Project {
        preconditionFailure("Not Implemented")
    }
    
    public func createProject(_ project: Project, action: CatalogAction) throws -> Project.ID {
        preconditionFailure("Not Implemented")
    }
    
    public func updateProject(_ project: Project, action: CatalogAction) throws {
        preconditionFailure("Not Implemented")
    }
    
    public func deleteProject(_ id: Project.ID, action: CatalogAction) throws {
        preconditionFailure("Not Implemented")
    }
    
    public func expressions() throws -> [Expression] {
        let entities = try db.expressionEntities()
        return try entities.compactMap({
            let translations = try db.translationEntities(forExpression: $0.id)
            return Expression($0, translations: translations)
        })
    }
    
    public func expression(_ id: Expression.ID) throws -> Expression {
        guard let entity = try db.expressionEntity(withUUID: id) else {
            throw Error.invalidExpressionID(id)
        }
        
        guard let expression = Expression(entity) else {
            throw Error.unhandledConversion
        }
        
        return expression
    }
    
    public func expressions(for project: Project.ID) throws -> [Expression] {
        preconditionFailure("Not Implemented")
    }
    
    public func expressions(matching query: CatalogQuery) throws -> [Expression] {
        guard let typedQuery = query as? Query else {
            throw Error.invalidQuery(query)
        }
        
        var entities: [ExpressionEntity] = []
        
        switch typedQuery {
        case .name(let name):
            try db.forEachRow(statement: .selectExpression(withName: name), handleRow: { (entity: ExpressionEntity) in
                entities.append(entity)
            })
        case .expression(let languageCode, let scriptCode, let regionCode):
            try db.forEachRow(statement: .selectExpressionsWith(languageCode: languageCode, scriptCode: scriptCode, regionCode: regionCode), handleRow: { (entity: ExpressionEntity) in
                entities.append(entity)
            })
        case .translation:
            break
        }
        
        return try entities.compactMap({
            let translations = try db.translationEntities(forExpression: $0.id)
            return Expression($0, translations: translations)
        })
    }
    
    public func createExpression(_ expression: Expression, action: CatalogAction) throws -> Expression.ID {
        if let existing = try? self.expression(expression.id), expression.id != .zero {
            throw Error.existingExpressionWithID(existing.id)
        }
        
        let id = UUID()
        var insert = ExpressionEntity(expression)
        insert.uuid = id.uuidString
        
        try db.execute(statement: .insertExpression(insert))
        let primaryKey = db.lastInsertRowID()
        
        if case .cascade = action as? InsertEntity {
            // Create any provided translations
            try expression.translations.forEach { (translation) in
                _ = try createTranslation(translation, action: InsertEntity.foreignKey(primaryKey))
            }
        }
        
        return id
    }
    
    public func updateExpression(_ id: Expression.ID, action: CatalogAction) throws {
        guard let entity = try? db.expressionEntity(withUUID: id) else {
            throw Error.invalidExpressionID(id)
        }
        
        guard let update = action as? SQLiteCatalog.ExpressionUpdate else {
            throw Error.invalidAction(action)
        }
        
        try db.execute(statement: .updateExpression(entity.id, update))
    }
    
    public func deleteExpression(_ id: Expression.ID, action: CatalogAction) throws {
        guard let entity = try? db.expressionEntity(withUUID: id) else {
            throw Error.invalidExpressionID(id)
        }
        
        try db.execute(statement: .deleteTranslations(withExpressionID: entity.id))
        try db.execute(statement: .deleteExpression(entity.id))
    }
    
    public func translations() throws -> [TranslationCatalog.Translation] {
        let expressionEntities = try db.expressionEntities()
        let translationEntities = try db.translationEntities()
        
        var output: [TranslationCatalog.Translation] = []
        translationEntities.forEach({ (entity) in
            if let expression = expressionEntities.first(where: { $0.id == entity.expressionID }) {
                if let translation = TranslationCatalog.Translation(entity, expressionUUID: expression.uuid) {
                    output.append(translation)
                }
            }
        })
        return output
    }
    
    public func translation(_ id: TranslationCatalog.Translation.ID) throws -> TranslationCatalog.Translation {
        guard let entity = try db.translationEntity(withUUID: id) else {
            throw Error.invalidTranslationID(id)
        }
        
        let expression = try? db.expressionEntity(withID: entity.expressionID)
        let expressionID = UUID(uuidString: expression?.uuid ?? "") ?? .zero
        
        guard let translation = TranslationCatalog.Translation(entity, expressionUUID: expressionID.uuidString) else {
            throw Error.unhandledConversion
        }
        
        return translation
    }
    
    public func translations(for expression: Expression.ID) throws -> [TranslationCatalog.Translation] {
        guard let entity = try db.expressionEntity(withUUID: expression) else {
            throw Error.invalidExpressionID(expression)
        }
        
        let entities = try db.translationEntities(forExpression: entity.id)
        return entities.compactMap({
            TranslationCatalog.Translation($0, expressionUUID: entity.uuid)
        })
    }
    
    public func translations(matching query: CatalogQuery) throws -> [TranslationCatalog.Translation] {
        guard let typedQuery = query as? Query else {
            throw Error.invalidQuery(query)
        }
        
        var entities: [TranslationEntity] = []
        var expressionID: Expression.ID
        
        switch typedQuery {
        case .translation(let expression, let language, let script, let region):
            expressionID = expression
            try db.forEachRow(statement: .selectTranslationsFor(expression, languageCode: language, scriptCode: script, regionCode: region), handleRow: { (entity: TranslationEntity) in
                entities.append(entity)
            })
        default:
            return []
        }
        
        return entities.compactMap({
            TranslationCatalog.Translation($0, expressionUUID: expressionID.uuidString)
        })
    }
    
    public func createTranslation(_ translation: TranslationCatalog.Translation, action: CatalogAction) throws -> TranslationCatalog.Translation.ID {
        if let existing = try? self.translation(translation.id), translation.id != .zero {
            throw Error.existingTranslationWithID(existing.id)
        }
        
        let id = UUID()
        var entity = TranslationEntity(translation)
        entity.uuid = id.uuidString
        
        if case let .foreignKey(expressionID) = action as? InsertEntity {
            // Override translation foreign key
            entity.expressionID = expressionID
        } else {
            // Search for expression with uuid
            guard let expression = try db.expressionEntity(withUUID: translation.expressionID) else {
                throw Error.invalidExpressionID(translation.expressionID)
            }
            
            entity.expressionID = expression.id
        }
        
        try db.execute(statement: .insertTranslation(entity))
        _ = db.lastInsertRowID() //primaryKey
        
        return id
    }
    
    public func updateTranslation(_ id: TranslationCatalog.Translation.ID, action: CatalogAction) throws {
        guard let entity = try? db.translationEntity(withUUID: id) else {
            throw Error.invalidTranslationID(id)
        }
        
        guard let update = action as? SQLiteCatalog.TranslationUpdate else {
            throw Error.invalidAction(action)
        }
        
        try db.execute(statement: .updateTranslation(entity.id, update))
    }
    
    public func deleteTranslation(_ id: TranslationCatalog.Translation.ID, action: CatalogAction) throws {
        guard let entity = try? db.translationEntity(withUUID: id) else {
            throw Error.invalidTranslationID(id)
        }
        
        try db.execute(statement: .deleteTranslation(entity.id))
    }
}
