import PerfectSQLite

extension SQLiteStmt {
    func optional<T>(position: Int) -> T? {
        guard !isNull(position: position) else {
            return nil
        }
        
        switch T.self {
        case is String.Type:
            return (columnText(position: position) as! T)
        default:
            return nil
        }
    }
}
