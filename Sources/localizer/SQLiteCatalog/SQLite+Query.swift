import PerfectSQLite
import StatementSQLite
import TranslationCatalog

extension SQLite {
    func execute(statement: SQLiteStatement) throws {
        try execute(statement: statement.render())
    }
    
    func execute(statement: SQLiteStatement, doBindings: (SQLiteStmt) throws -> ()) throws {
        try execute(statement: statement.render(), doBindings: doBindings)
    }
    
    func forEachRow(statement: SQLiteStatement, handleRow: (SQLiteStmt, Int) throws -> ()) throws {
        try forEachRow(statement: statement.render(), handleRow: handleRow)
    }
    
    func forEachRow(statement: SQLiteStatement, handleRow: (SQLiteCatalog.ExpressionEntity) throws -> ()) throws {
        try forEachRow(statement: statement.render()) { (stmt, index) in
            try handleRow(stmt.expressionEntity)
        }
    }
    
    func forEachRow(statement: SQLiteStatement, handleRow: (SQLiteCatalog.TranslationEntity) throws -> ()) throws {
        try forEachRow(statement: statement.render()) { (stmt, index) in
            try handleRow(stmt.translationEntity)
        }
    }
}

extension SQLite {
    func expressionEntities() throws -> [SQLiteCatalog.ExpressionEntity] {
        var output: [SQLiteCatalog.ExpressionEntity] = []
        try forEachRow(statement: .selectAllFromExpression, handleRow: { (entity: SQLiteCatalog.ExpressionEntity) in
            output.append(entity)
        })
        return output
    }
    
    func expressionEntity(withID id: Int) throws -> SQLiteCatalog.ExpressionEntity? {
        var output: SQLiteCatalog.ExpressionEntity?
        try forEachRow(statement: .selectExpression(withID: id)) { (entity: SQLiteCatalog.ExpressionEntity) in
            output = entity
        }
        return output
    }
    
    func expressionEntity(withUUID uuid: Expression.ID) throws -> SQLiteCatalog.ExpressionEntity? {
        var output: SQLiteCatalog.ExpressionEntity?
        try forEachRow(statement: .selectExpression(withID: uuid)) { (entity: SQLiteCatalog.ExpressionEntity) in
            output = entity
        }
        return output
    }
    
    func translationEntities() throws -> [SQLiteCatalog.TranslationEntity] {
        var output: [SQLiteCatalog.TranslationEntity] = []
        try forEachRow(statement: .selectAllFromTranslation, handleRow: { (entity: SQLiteCatalog.TranslationEntity) in
            output.append(entity)
        })
        return output
    }
    
    func translationEntity(withID id: Int) throws -> SQLiteCatalog.TranslationEntity? {
        var output: SQLiteCatalog.TranslationEntity?
        try forEachRow(statement: .selectTranslation(id), handleRow: { (entity: SQLiteCatalog.TranslationEntity) in
            output = entity
        })
        return output
    }
    
    func translationEntity(withUUID uuid: TranslationCatalog.Translation.ID) throws -> SQLiteCatalog.TranslationEntity? {
        var output: SQLiteCatalog.TranslationEntity?
        try forEachRow(statement: .selectTranslation(uuid), handleRow: { (entity: SQLiteCatalog.TranslationEntity) in
            output = entity
        })
        return output
    }
    
    func translationEntities(forExpression id: Int) throws -> [SQLiteCatalog.TranslationEntity] {
        var output: [SQLiteCatalog.TranslationEntity] = []
        try forEachRow(statement: .selectTranslationsFor(id), handleRow: { (entity: SQLiteCatalog.TranslationEntity) in
            output.append(entity)
        })
        return output
    }
}
