import Statement
import StatementSQLite
import TranslationCatalog

// MARK: - ProjectExpression (Schema)
extension SQLiteStatement {
    static var createProjectExpressionEntity: Self {
        .init(
            .CREATE(
                .SCHEMA(SQLiteCatalog.ProjectExpressionEntity.self, ifNotExists: true)
            )
        )
    }
}

// MARK: - ProjectExpression (Queries)
extension SQLiteStatement {
    static func insertProjectExpression(projectID: Int, expressionID: Int) -> Self {
        SQLiteStatement(
            .INSERT_INTO(
                SQLiteCatalog.ProjectExpressionEntity.self,
              .column(SQLiteCatalog.ProjectExpressionEntity.projectID),
              .column(SQLiteCatalog.ProjectExpressionEntity.expressionID)
            ),
            .VALUES(
                .value(projectID),
                .value(expressionID)
            )
        )
    }
    
    static func deleteProjectExpression(projectID: Int, expressionID: Int) -> Self {
        SQLiteStatement(
            .DELETE(
                .FROM(SQLiteCatalog.ProjectExpressionEntity.self)
            ),
            .WHERE(
                .AND(
                    .column(SQLiteCatalog.ProjectExpressionEntity.projectID, op: .equal, value: projectID),
                    .column(SQLiteCatalog.ProjectExpressionEntity.expressionID, op: .equal, value: expressionID)
                )
            ),
            .LIMIT(1)
        )
    }
    
    static func deleteProjectExpressions(projectID: Int) -> Self {
        SQLiteStatement(
            .DELETE(
                .FROM(SQLiteCatalog.ProjectExpressionEntity.self)
            ),
            .WHERE(
                .column(SQLiteCatalog.ProjectExpressionEntity.projectID, op: .equal, value: projectID)
            )
        )
    }
    
    static func deleteProjectExpressions(expressionID: Int) -> Self {
        SQLiteStatement(
            .DELETE(
                .FROM(SQLiteCatalog.ProjectExpressionEntity.self)
            ),
            .WHERE(
                .column(SQLiteCatalog.ProjectExpressionEntity.expressionID, op: .equal, value: expressionID)
            )
        )
    }
}
