import TranslationCatalog
import StatementSQLite
import PerfectSQLite

// MARK: - `Translation` Entity
extension SQLite {
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
    
    func translationEntities(withExpressionID id: Int) throws -> [SQLiteCatalog.TranslationEntity] {
        var output: [SQLiteCatalog.TranslationEntity] = []
        try forEachRow(statement: .selectTranslationsFor(id), handleRow: { (entity: SQLiteCatalog.TranslationEntity) in
            output.append(entity)
        })
        return output
    }
}
