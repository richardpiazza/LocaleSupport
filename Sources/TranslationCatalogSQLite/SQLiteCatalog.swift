import Foundation
import LocaleSupport
import TranslationCatalog
import PerfectSQLite
import StatementSQLite

/// An implementation of `TranslationCatalog.Catalog` using **SQLite**.
public class SQLiteCatalog: TranslationCatalog.Catalog {
    public typealias RenderedStatementHook = (String) -> Void
    
    private let db: SQLite
    /// A hook to observe statements that are rendered and executed.
    public var statementHook: RenderedStatementHook?
    
    public init(url: URL) throws {
        db = try SQLite(path: url.path, schema: .current)
    }
    
    deinit {
        db.close()
    }
    
    // MARK: - Project
    
    /// Retrieve all `Project`s in the catalog.
    ///
    /// ## SQLiteCatalog Notes
    ///
    /// This presents only a _shallow_ copy of the entities. In order to retrieve a _deep_ hierarchy, use `projects(matching:)` with
    /// the `SQLiteCatalog.ProjectQuery.hierarchy` option.
    public func projects() throws -> [Project] {
        let statement = renderStatement(.selectAllFromProject)
        return try db.projectEntities(statement: statement).map({ try $0.project() })
    }
    
    public func projects(matching query: CatalogQuery) throws -> [Project] {
        guard let _query = query as? SQLiteCatalog.ProjectQuery else {
            throw Error.invalidQuery(query)
        }
        
        var output: [Project] = []
        
        switch _query {
        case .hierarchy:
            let projectEntities = try db.projectEntities(statement: renderStatement(.selectAllFromProject))
            try projectEntities.forEach { p in
                let expressionEntities = try db.expressionEntities(statement: renderStatement(.selectExpressions(withProjectID: p.id)))
                var expressions: [Expression] = []
                try expressionEntities.forEach { e in
                    let translationEntities = try db.translationEntities(statement: renderStatement(.selectTranslationsFor(e.id)))
                    let translations = try translationEntities.map({ try $0.translation(with: e.uuid) })
                    expressions.append(try e.expression(with: translations))
                }
                
                output.append(try p.project(with: expressions))
            }
        case .named(let named):
            let entities = try db.projectEntities(statement: renderStatement(.selectProjects(withNameLike: named)))
            output = try entities.map({ try $0.project() })
        default:
            throw Error.unhandledQuery(query)
        }
        
        return output
    }
    
    public func project(_ id: Project.ID) throws -> Project {
        try project(matching: ProjectQuery.id(id))
    }
    
    public func project(matching query: CatalogQuery) throws -> Project {
        guard let _query = query as? SQLiteCatalog.ProjectQuery else {
            throw Error.invalidQuery(query)
        }
        
        switch _query {
        case .primaryKey(let id):
            guard let entity = try db.projectEntity(statement: renderStatement(.selectProject(withID: id))) else {
                throw Error.invalidPrimaryKey(id)
            }
            
            return try entity.project()
        case .id(let id):
            guard let entity = try db.projectEntity(statement: renderStatement(.selectProject(withID: id))) else {
                throw Error.invalidProjectID(id)
            }
            
            return try entity.project()
        case .named(let name):
            guard let entity = try db.projectEntity(statement: renderStatement(.selectProject(withName: name))) else {
                throw Error.invalidStringValue(name)
            }
            
            return try entity.project()
        default:
            throw Error.unhandledQuery(query)
        }
    }
    
    @discardableResult public func createProject(_ project: Project) throws -> Project.ID {
        if project.id != .zero {
            if let existing = try? self.project(project.id) {
                throw Error.invalidProjectID(existing.id)
            }
        }
        
        var id = project.id
        var entity = ProjectEntity(project)
        if project.id == .zero {
            id = UUID()
            entity.uuid = id.uuidString
        }
        
        try db.execute(statement: renderStatement(.insertProject(entity)))
        let primaryKey = db.lastInsertRowID()
        try project.expressions.forEach { expression in
            try insertAndLinkExpression(expression, projectID: primaryKey)
        }
        
        return id
    }
    
    public func updateProject(_ id: Project.ID, action: CatalogUpdate) throws {
        guard let entity = try db.projectEntity(statement: renderStatement(.selectProject(withID: id))) else {
            throw Error.invalidProjectID(id)
        }
        
        guard let update = action as? ProjectUpdate else {
            throw Error.invalidAction(action)
        }
        
        switch update {
        case .name(let name):
            try db.execute(statement: renderStatement(.updateProject(entity.id, name: name)))
        case .linkExpression(let uuid):
            guard let expression = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: uuid))) else {
                throw Error.invalidExpressionID(uuid)
            }
            
            try linkProject(entity.id, expressionID: expression.id)
        case .unlinkExpression(let uuid):
            guard let expression = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: uuid))) else {
                throw Error.invalidExpressionID(uuid)
            }
            
            try unlinkProject(entity.id, expressionID: expression.id)
        }
    }
    
    public func deleteProject(_ id: Project.ID) throws {
        guard let entity = try db.projectEntity(statement: renderStatement(.selectProject(withID: id))) else {
            throw Error.invalidProjectID(id)
        }
        
        try db.doWithTransaction {
            try db.execute(statement: renderStatement(.deleteProjectExpressions(projectID: entity.id)))
            try db.execute(statement: renderStatement(.deleteProject(entity.id)))
        }
    }
    
    // MARK: - Expression
    public func expressions() throws -> [Expression] {
        try db.expressionEntities(statement: renderStatement(.selectAllFromExpression)).map({ try $0.expression() })
    }
    
    public func expressions(matching query: CatalogQuery) throws -> [Expression] {
        guard let typedQuery = query as? ExpressionQuery else {
            throw Error.invalidQuery(query)
        }
        
        var output: [Expression] = []
        
        switch typedQuery {
        case .hierarchy:
            let expressionEntities = try db.expressionEntities(statement: renderStatement(.selectAllFromExpression))
            try expressionEntities.forEach { e in
                let translationEntities = try db.translationEntities(statement: renderStatement(.selectTranslationsFor(e.id)))
                let translations = try translationEntities.map({ try $0.translation(with: e.uuid) })
                output.append(try e.expression(with: translations))
            }
        case .projectID(let projectID):
            guard let project = try? db.projectEntity(statement: renderStatement(.selectProject(withID: projectID))) else {
                throw Error.invalidProjectID(projectID)
            }
            
            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressions(withProjectID: project.id)))
            output = try entities.map({ try $0.expression() })
        case .key(let key):
            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressions(withKeyLike: key)))
            output = try entities.map({ try $0.expression() })
        case .named(let name):
            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressions(withNameLike: name)))
            output = try entities.map({ try $0.expression() })
        case .having(let languageCode, let scriptCode, let regionCode):
            let entities = try db.expressionEntities(statement: renderStatement(.selectExpressionsWith(languageCode: languageCode, scriptCode: scriptCode, regionCode: regionCode)))
            output = try entities.map({ try $0.expression() })
        default:
            throw Error.unhandledQuery(query)
        }
        
        return output
    }
    
    public func expression(_ id: Expression.ID) throws -> Expression {
        try expression(matching: ExpressionQuery.id(id))
    }
    
    public func expression(matching query: CatalogQuery) throws -> Expression {
        guard let _query = query as? SQLiteCatalog.ExpressionQuery else {
            throw Error.invalidQuery(query)
        }
        
        switch _query {
        case .primaryKey(let id):
            guard let entity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: id))) else {
                throw Error.invalidPrimaryKey(id)
            }
            
            return try entity.expression()
        case .id(let uuid):
            guard let entity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: uuid))) else {
                throw Error.invalidExpressionID(uuid)
            }
            
            return try entity.expression()
        default:
            throw Error.unhandledQuery(query)
        }
    }
    
    /// Insert a `Expression` into the catalog.
    ///
    /// ## SQLiteCatalog Notes:
    ///
    /// * If a `Expression.ID` is specified (non-zero), and a matching entity is found, the insert will fail.
    /// * If an entity with a matching `Expression.key` is found, the insert will fail. (Keys must be unique)
    ///
    /// - parameter expression: The entity to insert.
    /// - returns The unique identifier created for the new entity.
    @discardableResult public func createExpression(_ expression: Expression) throws -> Expression.ID {
        if expression.id != .zero {
            if let existing = try? self.expression(expression.id) {
                throw Error.existingExpressionWithID(existing.id)
            }
        }
        
        if let existingKey = try? db.expressionEntity(statement: renderStatement(.selectExpression(withKey: expression.key))) {
            throw Error.existingExpressionWithKey(existingKey.key)
        }
        
        var id = expression.id
        var entity = ExpressionEntity(expression)
        if expression.id == .zero {
            id = UUID()
            entity.uuid = id.uuidString
        }
        
        try db.execute(statement: renderStatement(.insertExpression(entity)))
        try expression.translations.forEach { (translation) in
            var t = translation
            t.expressionID = id
            try createTranslation(t)
        }
        
        return id
    }
    
    public func updateExpression(_ id: Expression.ID, action: CatalogUpdate) throws {
        guard let entity = try? db.expressionEntity(statement: renderStatement(.selectExpression(withID: id))) else {
            throw Error.invalidExpressionID(id)
        }
        
        guard let update = action as? SQLiteCatalog.ExpressionUpdate else {
            throw Error.invalidAction(action)
        }
        
        switch update {
        case .key(let key) where key != entity.key:
            try db.execute(statement: renderStatement(.updateExpression(entity.id, key: key)))
        case .name(let name) where name != entity.name:
            try db.execute(statement: renderStatement(.updateExpression(entity.id, name: name)))
        case .defaultLanguage(let languageCode) where languageCode.rawValue != entity.defaultLanguage:
            try db.execute(statement: renderStatement(.updateExpression(entity.id, defaultLanguage: languageCode)))
        case .context(let context) where context != entity.context:
            try db.execute(statement: renderStatement(.updateExpression(entity.id, context: context)))
        case .feature(let feature) where feature != entity.feature:
            try db.execute(statement: renderStatement(.updateExpression(entity.id, feature: feature)))
        case .linkProject(let uuid):
            guard let project = try db.projectEntity(statement: renderStatement(.selectProject(withID: uuid))) else {
                throw Error.invalidProjectID(uuid)
            }
            
            try linkProject(project.id, expressionID: entity.id)
        case .unlinkProject(let uuid):
            guard let project = try db.projectEntity(statement: renderStatement(.selectProject(withID: uuid))) else {
                throw Error.invalidProjectID(uuid)
            }
            
            try unlinkProject(project.id, expressionID: entity.id)
        default:
            // Update requested where action values are already equivalent
            break
        }
    }
    
    public func deleteExpression(_ id: Expression.ID) throws {
        guard let entity = try? db.expressionEntity(statement: renderStatement(.selectExpression(withID: id))) else {
            throw Error.invalidExpressionID(id)
        }
        
        try db.doWithTransaction {
            try db.execute(statement: renderStatement(.deleteTranslations(withExpressionID: entity.id)))
            try db.execute(statement: renderStatement(.deleteProjectExpressions(expressionID: entity.id)))
            try db.execute(statement: renderStatement(.deleteExpression(entity.id)))
        }
    }
    
    // MARK: - Translation
    public func translations() throws -> [TranslationCatalog.Translation] {
        // A bit of annoying implementation detail: Since the SQLite database is using a Integer foreign key,
        // in order to map the entity to the struct, a double query needs to be performed.
        // Storing the expression uuid on the translation entity would be one was to counter this.
        // TODO: Render with statement when 'AS' becomes available.
        
        let expressionEntities = try db.expressionEntities(statement: renderStatement(.selectAllFromExpression))
        let translationEntities = try db.translationEntities(statement: renderStatement(.selectAllFromTranslation))
        
        var output: [TranslationCatalog.Translation] = []
        try translationEntities.forEach({ (entity) in
            if let expression = expressionEntities.first(where: { $0.id == entity.expressionID }) {
                output.append(try entity.translation(with: expression.uuid))
            }
        })
        return output
    }
    
    public func translations(matching query: CatalogQuery) throws -> [TranslationCatalog.Translation] {
        guard let typedQuery = query as? TranslationQuery else {
            throw Error.invalidQuery(query)
        }
        
        var output: [TranslationCatalog.Translation] = []
        
        switch typedQuery {
        case .expressionID(let expressionUUID):
            guard let expressionEntity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: expressionUUID))) else {
                throw Error.invalidExpressionID(expressionUUID)
            }
            
            let entities = try db.translationEntities(statement: renderStatement(.selectTranslationsFor(expressionEntity.id)))
            try entities.forEach({
                output.append(try $0.translation(with: expressionEntity.uuid))
            })
        case .having(let expression, let language, let script, let region):
            let entities = try db.translationEntities(statement: renderStatement(.selectTranslationsFor(expression, languageCode: language, scriptCode: script, regionCode: region)))
            try entities.forEach({
                output.append(try $0.translation(with: expression.uuidString))
            })
        default:
            throw Error.unhandledQuery(query)
        }
        
        return output
    }
    
    public func translation(_ id: TranslationCatalog.Translation.ID) throws -> TranslationCatalog.Translation {
        try translation(matching: TranslationQuery.id(id))
    }
    
    public func translation(matching query: CatalogQuery) throws -> TranslationCatalog.Translation {
        guard let _query = query as? SQLiteCatalog.TranslationQuery else {
            throw Error.invalidQuery(query)
        }
        
        let entity: TranslationEntity
        
        switch _query {
        case .primaryKey(let id):
            guard let _entity = try db.translationEntity(statement: renderStatement(.selectTranslation(withID: id))) else {
                throw Error.invalidPrimaryKey(id)
            }
            entity = _entity
        case .id(let uuid):
            guard let _entity = try db.translationEntity(statement: renderStatement(.selectTranslation(withID: uuid))) else {
                throw Error.invalidTranslationID(uuid)
            }
            entity = _entity
        default:
            throw Error.unhandledQuery(query)
        }
        
        guard let expressionEntity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: entity.expressionID))) else {
            throw Error.invalidPrimaryKey(entity.expressionID)
        }
        
        return try entity.translation(with: expressionEntity.uuid)
    }
    
    /// Insert a `Translation` into the catalog.
    ///
    /// ## SQLiteCatalog Notes:
    ///
    /// * A `Expression` with `Translation.expressionID` must already exist, or the insert will fail.
    /// * If a `Translation.ID` is specified (non-zero), and a matching entity is found, the insert will fail.
    ///
    /// - parameter translation: The entity to insert.
    /// - returns The unique identifier created for the new entity.
    @discardableResult public func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID {
        if translation.id != .zero {
            if let existing = try? self.translation(translation.id) {
                throw Error.existingTranslationWithID(existing.id)
            }
        }
        
        guard let expression = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: translation.expressionID))) else {
            throw Error.invalidExpressionID(translation.expressionID)
        }
        
        var id = translation.id
        var entity = TranslationEntity(translation)
        if translation.id == .zero {
            id = UUID()
            entity.uuid = id.uuidString
        }
        entity.expressionID = expression.id
        
        try db.execute(statement: renderStatement(.insertTranslation(entity)))
        
        return id
    }
    
    public func updateTranslation(_ id: TranslationCatalog.Translation.ID, action: CatalogUpdate) throws {
        guard let entity = try? db.translationEntity(statement: renderStatement(.selectTranslation(withID: id))) else {
            throw Error.invalidTranslationID(id)
        }
        
        guard let update = action as? SQLiteCatalog.TranslationUpdate else {
            throw Error.invalidAction(action)
        }
        
        switch update {
        case .language(let languageCode) where languageCode.rawValue != entity.language:
            try db.execute(statement: renderStatement(.updateTranslation(entity.id, languageCode: languageCode)))
        case .script(let scriptCode) where scriptCode?.rawValue != entity.script:
            try db.execute(statement: renderStatement(.updateTranslation(entity.id, scriptCode: scriptCode)))
        case .region(let regionCode) where regionCode?.rawValue != entity.region:
            try db.execute(statement: renderStatement(.updateTranslation(entity.id, regionCode: regionCode)))
        case .value(let value) where value != entity.value:
            try db.execute(statement: renderStatement(.updateTranslation(entity.id, value: value)))
        default:
            // Update requested where action values are already equivalent
            break
        }
    }
    
    public func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws {
        guard let entity = try? db.translationEntity(statement: renderStatement(.selectTranslation(withID: id))) else {
            throw Error.invalidTranslationID(id)
        }
        
        try db.doWithTransaction {
            try db.execute(statement: renderStatement(.deleteTranslation(entity.id)))
        }
    }
}

private extension SQLiteCatalog {
    func renderStatement(_ statement: SQLiteStatement) -> String {
        let rendered = statement.render()
        statementHook?(rendered)
        return rendered
    }
    
    /// Creates an `Expression` (if needed) , and links to the provided project
    func insertAndLinkExpression(_ expression: Expression, projectID: Int) throws {
        // Link Only
        if let entity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: expression.id))) {
            try linkProject(projectID, expressionID: entity.id)
            return
        }
        
        // Create & Link
        let uuid = try createExpression(expression)
        guard let entity = try db.expressionEntity(statement: renderStatement(.selectExpression(withID: uuid))) else {
            throw Error.invalidExpressionID(uuid)
        }
        
        try linkProject(projectID, expressionID: entity.id)
    }
    
    func linkProject(_ projectID: Int, expressionID: Int) throws {
        if let _ = try db.projectExpressionEntity(statement: renderStatement(.selectProjectExpression(projectID: projectID, expressionID: expressionID))) {
            // Link exists
            return
        }
        
        try db.execute(statement: renderStatement(.insertProjectExpression(projectID: projectID, expressionID: expressionID)))
    }
    
    func unlinkProject(_ projectID: Int, expressionID: Int) throws {
        guard let _ = try db.projectExpressionEntity(statement: renderStatement(.selectProjectExpression(projectID: projectID, expressionID: expressionID))) else {
            return
        }
        
        try db.execute(statement: renderStatement(.deleteProjectExpression(projectID: projectID, expressionID: expressionID)))
    }
}
