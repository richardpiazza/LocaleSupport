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
    
    func forEachRow(statement: SQLiteStatement, handleRow: (SQLiteCatalog.ProjectEntity) throws -> ()) throws {
        try forEachRow(statement: statement.render()) { (stmt, index) in
            try handleRow(stmt.projectEntity)
        }
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
