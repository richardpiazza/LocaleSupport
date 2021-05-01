import Foundation
import LocaleSupport
import TranslationCatalog
import PerfectSQLite

public class SQLiteCatalog: TranslationCatalog.Catalog {
    
    private let db: SQLite
    
    public init() throws {
        db = try SQLite(schema: .current)
    }
    
    deinit {
        db.close()
    }
    
    // MARK: - Project
    public func projects() throws -> [Project] {
        try db.projectEntities().map({ try $0.project() })
    }
    
    public func projects(matching query: CatalogQuery) throws -> [Project] {
        guard let _query = query as? SQLiteCatalog.Query else {
            throw Error.invalidQuery(query)
        }
        
        var output: [Project] = []
        
        switch _query {
        case .cascade:
            let projectEntities = try db.projectEntities()
            try projectEntities.forEach { p in
                let expressionEntities = try db.expressionEntities(withProjectID: p.id)
                var expressions: [Expression] = []
                try expressionEntities.forEach { e in
                    let translationEntities = try db.translationEntities(withExpressionID: e.id)
                    let translations = try translationEntities.map({ try $0.translation(with: e.uuid) })
                    expressions.append(try e.expression(with: translations))
                }
                
                output.append(try p.project(with: expressions))
            }
        default:
            break
        }
        
        return output
    }
    
    public func project(_ id: Project.ID) throws -> Project {
        try project(matching: Query.primaryID(id))
    }
    
    public func project(matching query: CatalogQuery) throws -> Project {
        guard let _query = query as? SQLiteCatalog.Query else {
            throw Error.invalidQuery(query)
        }
        
        switch _query {
        case .primaryKey(let id):
            guard let entity = try db.projectEntity(withID: id) else {
                throw Error.invalidPrimaryKey(id)
            }
            
            return try entity.project()
        case .primaryID(let uuid):
            guard let entity = try db.projectEntity(withUUID: uuid) else {
                throw Error.invalidProjectID(uuid)
            }
            
            return try entity.project()
        default:
            break
        }
        
        throw Error.invalidQuery(query)
    }
    
    public func createProject(_ project: Project, action: CatalogAction) throws -> Project.ID {
        if let existing = try? self.project(project.id), project.id != .zero {
            throw Error.invalidProjectID(existing.id)
        }
        
        let id = UUID()
        var entity = ProjectEntity(project)
        entity.uuid = id.uuidString
        
        try db.doWithTransaction {
            try db.execute(statement: .insertProject(entity))
        }
        
        return id
    }
    
    public func updateProject(_ project: Project, action: CatalogAction) throws {
        guard let entity = try db.projectEntity(withUUID: project.id) else {
            throw Error.invalidProjectID(project.id)
        }
        
        guard let update = action as? ProjectUpdate else {
            throw Error.invalidAction(action)
        }
        
        switch update {
        case .name(let name):
            try db.doWithTransaction {
                try db.execute(statement: .updateProject(entity.id, name: name))
            }
        }
    }
    
    public func deleteProject(_ id: Project.ID, action: CatalogAction) throws {
        guard let entity = try db.projectEntity(withUUID: id) else {
            throw Error.invalidProjectID(id)
        }
        
        try db.doWithTransaction {
            try db.execute(statement: .deleteProjectExpressions(projectID: entity.id))
            try db.execute(statement: .deleteProject(entity.id))
        }
    }
    
    // MARK: - Expression
    public func expressions() throws -> [Expression] {
        try db.expressionEntities().map({ try $0.expression() })
    }
    
    public func expressions(matching query: CatalogQuery) throws -> [Expression] {
        guard let typedQuery = query as? Query else {
            throw Error.invalidQuery(query)
        }
        
        var output: [Expression] = []
        
        switch typedQuery {
        case .cascade:
            let expressionEntities = try db.expressionEntities()
            try expressionEntities.forEach { e in
                let translationEntities = try db.translationEntities(withExpressionID: e.id)
                let translations = try translationEntities.map({ try $0.translation(with: e.uuid) })
                output.append(try e.expression(with: translations))
            }
        case .expression(let languageCode, let scriptCode, let regionCode):
            try db.forEachRow(statement: .selectExpressionsWith(languageCode: languageCode, scriptCode: scriptCode, regionCode: regionCode), handleRow: { (entity: ExpressionEntity) in
                output.append(try entity.expression())
            })
        default:
            break
        }
        
        return output
    }
    
    public func expression(_ id: Expression.ID) throws -> Expression {
        try expression(matching: Query.primaryID(id))
    }
    
    public func expression(matching query: CatalogQuery) throws -> Expression {
        guard let _query = query as? SQLiteCatalog.Query else {
            throw Error.invalidQuery(query)
        }
        
        switch _query {
        case .primaryKey(let id):
            guard let entity = try db.expressionEntity(withID: id) else {
                throw Error.invalidPrimaryKey(id)
            }
            
            return try entity.expression()
        case .primaryID(let uuid):
            guard let entity = try db.expressionEntity(withUUID: uuid) else {
                throw Error.invalidExpressionID(uuid)
            }
            
            return try entity.expression()
        default:
            break
        }
        
        throw Error.invalidQuery(query)
    }
    
    public func createExpression(_ expression: Expression, action: CatalogAction) throws -> Expression.ID {
        if let existing = try? self.expression(expression.id), expression.id != .zero {
            throw Error.existingExpressionWithID(existing.id)
        }
        
        if let existingEntity = try? db.expressionEntity(withKey: expression.key), !expression.key.isEmpty {
            if case .cascade = action as? InsertEntity {
                try expression.translations.forEach { (translation) in
                    _ = try createTranslation(translation, action: InsertEntity.foreignKey(existingEntity.id))
                }
            }
            
            return UUID(uuidString: existingEntity.uuid) ?? .zero
        }
        
        let id = UUID()
        var entity = ExpressionEntity(expression)
        entity.uuid = id.uuidString
        
        try db.execute(statement: .insertExpression(entity))
        let primaryKey = db.lastInsertRowID()
        
        if case .cascade = action as? InsertEntity {
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
        
        switch update {
        case .key(let key) where key != entity.key:
            try db.execute(statement: .updateExpression(entity.id, key: key))
        case .name(let name) where name != entity.name:
            try db.execute(statement: .updateExpression(entity.id, name: name))
        case .defaultLanguage(let languageCode) where languageCode.rawValue != entity.defaultLanguage:
            try db.execute(statement: .updateExpression(entity.id, defaultLanguage: languageCode))
        case .context(let context) where context != entity.context:
            try db.execute(statement: .updateExpression(entity.id, context: context))
        case .feature(let feature) where feature != entity.feature:
            try db.execute(statement: .updateExpression(entity.id, feature: feature))
        default:
            // Update requested where action values are already equivalent
            break
        }
    }
    
    public func deleteExpression(_ id: Expression.ID, action: CatalogAction) throws {
        guard let entity = try? db.expressionEntity(withUUID: id) else {
            throw Error.invalidExpressionID(id)
        }
        
        try db.doWithTransaction {
            try db.execute(statement: .deleteTranslations(withExpressionID: entity.id))
            try db.execute(statement: .deleteExpression(entity.id))
        }
    }
    
    // MARK: - Translation
    public func translations() throws -> [TranslationCatalog.Translation] {
        // A bit of annoying implementation detail: Since the SQLite database is using a Integer foreign key,
        // in order to map the entity to the struct, a double query needs to be performed.
        // Storing the expression uuid on the translation entity would be one was to counter this.
        
        let expressionEntities = try db.expressionEntities()
        let translationEntities = try db.translationEntities()
        
        var output: [TranslationCatalog.Translation] = []
        try translationEntities.forEach({ (entity) in
            if let expression = expressionEntities.first(where: { $0.id == entity.expressionID }) {
                output.append(try entity.translation(with: expression.uuid))
            }
        })
        return output
    }
    
    public func translations(matching query: CatalogQuery) throws -> [TranslationCatalog.Translation] {
        guard let typedQuery = query as? Query else {
            throw Error.invalidQuery(query)
        }
        
        var output: [TranslationCatalog.Translation] = []
        
        switch typedQuery {
        case .foreignID(let expressionUUID):
            guard let expressionEntity = try db.expressionEntity(withUUID: expressionUUID) else {
                throw Error.invalidExpressionID(expressionUUID)
            }
            
            let entities = try db.translationEntities(withExpressionID: expressionEntity.id)
            try entities.forEach({
                output.append(try $0.translation(with: expressionEntity.uuid))
            })
        case .translation(let expression, let language, let script, let region):
            try db.forEachRow(statement: .selectTranslationsFor(expression, languageCode: language, scriptCode: script, regionCode: region), handleRow: { (entity: TranslationEntity) in
                output.append(try entity.translation(with: expression.uuidString))
            })
        default:
            break
        }
        
        return output
    }
    
    public func translation(_ id: TranslationCatalog.Translation.ID) throws -> TranslationCatalog.Translation {
        try translation(matching: Query.primaryID(id))
    }
    
    public func translation(matching query: CatalogQuery) throws -> TranslationCatalog.Translation {
        guard let _query = query as? SQLiteCatalog.Query else {
            throw Error.invalidQuery(query)
        }
        
        let entity: TranslationEntity
        
        switch _query {
        case .primaryKey(let id):
            guard let _entity = try db.translationEntity(withID: id) else {
                throw Error.invalidPrimaryKey(id)
            }
            entity = _entity
        case .primaryID(let uuid):
            guard let _entity = try db.translationEntity(withUUID: uuid) else {
                throw Error.invalidTranslationID(uuid)
            }
            entity = _entity
        default:
            throw Error.invalidQuery(query)
        }
        
        guard let expressionEntity = try db.expressionEntity(withID: entity.expressionID) else {
            throw Error.invalidPrimaryKey(entity.expressionID)
        }
        
        return try entity.translation(with: expressionEntity.uuid)
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
        
        switch update {
        case .language(let languageCode) where languageCode.rawValue != entity.language:
            try db.execute(statement: .updateTranslation(entity.id, languageCode: languageCode))
        case .script(let scriptCode) where scriptCode?.rawValue != entity.script:
            try db.execute(statement: .updateTranslation(entity.id, scriptCode: scriptCode))
        case .region(let regionCode) where regionCode?.rawValue != entity.region:
            try db.execute(statement: .updateTranslation(entity.id, regionCode: regionCode))
        case .value(let value) where value != entity.value:
            try db.execute(statement: .updateTranslation(entity.id, value: value))
        default:
            // Update requested where action values are already equivalent
            break
        }
    }
    
    public func deleteTranslation(_ id: TranslationCatalog.Translation.ID, action: CatalogAction) throws {
        guard let entity = try? db.translationEntity(withUUID: id) else {
            throw Error.invalidTranslationID(id)
        }
        
        try db.execute(statement: .deleteTranslation(entity.id))
    }
}
