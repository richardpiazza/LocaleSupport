import TranslationCatalog
import StatementSQLite
import PerfectSQLite

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
    
    func forEachRow(statement: SQLiteStatement, handleRow: (ProjectEntity) throws -> ()) throws {
        try forEachRow(statement: statement.render()) { (stmt, index) in
            try handleRow(stmt.projectEntity)
        }
    }
    
    func forEachRow(statement: SQLiteStatement, handleRow: (ProjectExpressionEntity) throws -> ()) throws {
        try forEachRow(statement: statement.render()) { (stmt, index) in
            try handleRow(stmt.projectExpressionEntity)
        }
    }
    
    func forEachRow(statement: SQLiteStatement, handleRow: (ExpressionEntity) throws -> ()) throws {
        try forEachRow(statement: statement.render()) { (stmt, index) in
            try handleRow(stmt.expressionEntity)
        }
    }
    
    func forEachRow(statement: SQLiteStatement, handleRow: (TranslationEntity) throws -> ()) throws {
        try forEachRow(statement: statement.render()) { (stmt, index) in
            try handleRow(stmt.translationEntity)
        }
    }
}

// MARK: - `Project` Entity
extension SQLite {
    func projectEntities(_ statement: SQLiteStatement = .selectAllFromProject) throws -> [ProjectEntity] {
        var output: [ProjectEntity] = []
        try forEachRow(statement: statement, handleRow: { (entity: ProjectEntity) in
            output.append(entity)
        })
        return output
    }
    
    func projectEntity(_ statement: SQLiteStatement) throws -> ProjectEntity? {
        var output: ProjectEntity?
        try forEachRow(statement: statement, handleRow: { (entity: ProjectEntity) in
            output = entity
        })
        return output
    }
}

// MARK: - `ProjectExpression` Entity
extension SQLite {
    func projectExpressionEntity(projectID: Int, expressionID: Int) throws -> ProjectExpressionEntity? {
        var output: ProjectExpressionEntity?
        try forEachRow(statement: .selectProjectExpression(projectID: projectID, expressionID: expressionID)) { (entity: ProjectExpressionEntity) in
            output = entity
        }
        return output
    }
}

// MARK: - `Expression` Entity
extension SQLite {
    func expressionEntities(_ statement: SQLiteStatement = .selectAllFromExpression) throws -> [ExpressionEntity] {
        var output: [ExpressionEntity] = []
        try forEachRow(statement: statement, handleRow: { (entity: ExpressionEntity) in
            output.append(entity)
        })
        
        return output
    }
    
    func expressionEntity(_ statement: SQLiteStatement) throws -> ExpressionEntity? {
        var output: ExpressionEntity?
        try forEachRow(statement: statement) { (entity: ExpressionEntity) in
            output = entity
        }
        return output
    }
}

// MARK: - `Translation` Entity
extension SQLite {
    func translationEntities(_ statement: SQLiteStatement = .selectAllFromTranslation) throws -> [TranslationEntity] {
        var output: [TranslationEntity] = []
        try forEachRow(statement: .selectAllFromTranslation, handleRow: { (entity: TranslationEntity) in
            output.append(entity)
        })
        return output
    }
    
    func translationEntity(_ statement: SQLiteStatement) throws -> TranslationEntity? {
        var output: TranslationEntity?
        try forEachRow(statement: statement, handleRow: { (entity: TranslationEntity) in
            output = entity
        })
        return output
    }
}
