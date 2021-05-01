import TranslationCatalog
import StatementSQLite
import PerfectSQLite

// MARK: - `ProjectExpression` Entity
extension SQLite {
    func projectExpressionEntity(projectID: Int, expressionID: Int) throws -> SQLiteCatalog.ProjectExpressionEntity? {
        var output: SQLiteCatalog.ProjectExpressionEntity?
        try forEachRow(statement: .selectProjectExpression(projectID: projectID, expressionID: expressionID)) { (entity: SQLiteCatalog.ProjectExpressionEntity) in
            output = entity
        }
        return output
    }
}
