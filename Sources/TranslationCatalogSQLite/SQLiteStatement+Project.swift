import Statement
import StatementSQLite
import TranslationCatalog

// MARK: - Project (Schema)
extension SQLiteStatement {
    static var createProjectEntity: Self {
        .init(
            .CREATE(
                .SCHEMA(SQLiteCatalog.ProjectEntity.self, ifNotExists: true)
            )
        )
    }
}

// MARK: - Project (Queries)
extension SQLiteStatement {
    static var selectAllFromProject: Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.ProjectEntity.id),
                .column(SQLiteCatalog.ProjectEntity.uuid),
                .column(SQLiteCatalog.ProjectEntity.name)
            ),
            .FROM(
                .TABLE(SQLiteCatalog.ProjectEntity.self)
            )
        )
    }
    
    static func selectProject(withID id: Int) -> Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.ProjectEntity.id),
                .column(SQLiteCatalog.ProjectEntity.uuid),
                .column(SQLiteCatalog.ProjectEntity.name)
            ),
            .FROM(
                .TABLE(SQLiteCatalog.ProjectEntity.self)
            ),
            .WHERE(
                .column(SQLiteCatalog.ProjectEntity.id, op: .equal, value: id)
            )
        )
    }
    
    static func selectProject(withID id: Project.ID) -> Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.ProjectEntity.id),
                .column(SQLiteCatalog.ProjectEntity.uuid),
                .column(SQLiteCatalog.ProjectEntity.name)
            ),
            .FROM(
                .TABLE(SQLiteCatalog.ProjectEntity.self)
            ),
            .WHERE(
                .column(SQLiteCatalog.ProjectEntity.uuid, op: .equal, value: id)
            )
        )
    }
    
    static func insertProject(_ project: SQLiteCatalog.ProjectEntity) -> Self {
        SQLiteStatement(
            .INSERT_INTO(
                SQLiteCatalog.ProjectEntity.self,
                .column(SQLiteCatalog.ProjectEntity.uuid),
                .column(SQLiteCatalog.ProjectEntity.name)
            ),
            .VALUES(
                .value(project.uuid),
                .value(project.name)
            )
        )
    }
    
    static func updateProject(_ id: Int, name: String) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(SQLiteCatalog.ProjectEntity.self)
            ),
            .SET(
                .column(SQLiteCatalog.ProjectEntity.name, op: .equal, value: name)
            ),
            .WHERE(
                .column(SQLiteCatalog.ProjectEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func deleteProject(_ id: Int) -> Self {
        SQLiteStatement(
            .DELETE(
                .FROM(SQLiteCatalog.ProjectEntity.self)
            ),
            .WHERE(
                .column(SQLiteCatalog.ProjectEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
}
