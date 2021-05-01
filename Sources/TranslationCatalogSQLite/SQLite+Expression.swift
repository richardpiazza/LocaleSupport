import TranslationCatalog
import StatementSQLite
import PerfectSQLite

// MARK: - `Expression` Entity
extension SQLite {
    func expressionEntities() throws -> [SQLiteCatalog.ExpressionEntity] {
        var output: [SQLiteCatalog.ExpressionEntity] = []
        try forEachRow(statement: .selectAllFromExpression, handleRow: { (entity: SQLiteCatalog.ExpressionEntity) in
            output.append(entity)
        })
        
        return output
    }
    
    func expressionEntities(withProjectID id: Int) throws -> [SQLiteCatalog.ExpressionEntity] {
        var output: [SQLiteCatalog.ExpressionEntity] = []
        try forEachRow(statement: .selectExpressions(withProjectID: id), handleRow: { (entity: SQLiteCatalog.ExpressionEntity) in
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
    
    func expressionEntity(withKey key: String) throws -> SQLiteCatalog.ExpressionEntity? {
        var output: SQLiteCatalog.ExpressionEntity?
        try forEachRow(statement: .selectExpression(withKey: key)) { (entity: SQLiteCatalog.ExpressionEntity) in
            output = entity
        }
        return output
    }
}
