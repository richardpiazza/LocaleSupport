import TranslationCatalog
import StatementSQLite
import PerfectSQLite

// MARK: - `Project` Entity
extension SQLite {
    func projectEntities() throws -> [SQLiteCatalog.ProjectEntity] {
        var output: [SQLiteCatalog.ProjectEntity] = []
        try forEachRow(statement: .selectAllFromProject, handleRow: { (entity: SQLiteCatalog.ProjectEntity) in
            output.append(entity)
        })
        return output
    }
    
    func projectEntities(forProjectID id: Int) throws -> [SQLiteCatalog.ProjectEntity] {
        var output: [SQLiteCatalog.ProjectEntity] = []
        try forEachRow(statement: .selectAllFromProject, handleRow: { (entity: SQLiteCatalog.ProjectEntity) in
            output.append(entity)
        })
        return output
    }
    
    func projectEntity(withID id: Int) throws -> SQLiteCatalog.ProjectEntity? {
        var output: SQLiteCatalog.ProjectEntity?
        try forEachRow(statement: .selectProject(withID: id), handleRow: { (entity: SQLiteCatalog.ProjectEntity) in
            output = entity
        })
        return output
    }
    
    func projectEntity(withUUID uuid: Project.ID) throws -> SQLiteCatalog.ProjectEntity? {
        var output: SQLiteCatalog.ProjectEntity?
        try forEachRow(statement: .selectProject(withID: uuid), handleRow: { (entity: SQLiteCatalog.ProjectEntity) in
            output = entity
        })
        return output
    }
}
