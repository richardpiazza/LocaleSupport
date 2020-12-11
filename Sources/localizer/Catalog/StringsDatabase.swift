import Foundation
import PerfectSQLite

public class StringsDatabase: Database {
    
    private let db: SQLite
    
    public init(path: String) throws {
        db = try SQLite(path)
        try createSchema()
    }
    
    deinit {
        db.close()
    }
    
    private func createSchema() throws {
        try db.execute(statement: """
        CREATE TABLE IF NOT EXISTS "key" (
            "id" INTEGER NOT NULL UNIQUE,
            "name" Text NOT NULL,
            "comment" Text,
            PRIMARY KEY("id" AUTOINCREMENT)
        );
        """)
        
        try db.execute(statement: """
        CREATE TABLE IF NOT EXISTS "value" (
            "id" INTEGER NOT NULL UNIQUE,
            "key"  INTEGER NOT NULL,
            "language_code"  TEXT NOT NULL,
            "region_code"  TEXT,
            "localization"  TEXT NOT NULL,
            PRIMARY KEY("id" AUTOINCREMENT)
            FOREIGN KEY(key) REFERENCES key(id)
        );
        """)
    }
    
    public func keys(includeValues: Bool) -> [Key] {
        var keys: [Key] = []
        
        do {
            try db.forEachRow(statement: """
            SELECT "id", "name", "comment"
            FROM "key";
            """, handleRow: { (statement, index) in
                var key = Key(
                    id: statement.columnInt(position: 0),
                    name: statement.columnText(position: 1),
                    comment: statement.optional(position: 2)
                )
                if includeValues {
                    key.values = values(for: key.id)
                }
                keys.append(key)
            })
        } catch {
            print(error)
        }
        
        return keys
    }
    
    public func key(_ id: Key.ID) -> Key? {
        var key: Key?
        
        do {
            try db.forEachRow(statement: """
            SELECT "id", "name", "comment"
            FROM "key"
            WHERE "id" = :1
            LIMIT 1;
            """, doBindings: { (statement) in
                try statement.bind(position: 1, id)
            }, handleRow: { (statement, index) in
                key = Key(
                    id: statement.columnInt(position: 0),
                    name: statement.columnText(position: 1),
                    comment: statement.optional(position: 2)
                )
            })
        } catch {
            print(error)
        }
        
        return key
    }
    
    public func key(named name: String) -> Key? {
        var key: Key?
        
        do {
            try db.forEachRow(statement: """
            SELECT "id", "name", "comment"
            FROM "key"
            WHERE "name" = :1
            LIMIT 1;
            """, doBindings: { (statement) in
                try statement.bind(position: 1, name)
            }, handleRow: { (statement, index) in
                key = Key(
                    id: statement.columnInt(position: 0),
                    name: statement.columnText(position: 1),
                    comment: statement.optional(position: 2)
                )
            })
        } catch {
            print(error)
        }
        
        return key
    }
    
    public func keys(havingLanguage language: LanguageCode, region: RegionCode?) -> [Key] {
        var keys: [Key] = []
        
        do {
            switch region {
            case .some(let reg) where !reg.isEmpty:
                try db.forEachRow(statement: """
                SELECT  "key"."id", "name", "comment"
                FROM "key"
                JOIN "value" ON "key"."id" = "value"."key"
                WHERE "value"."language_code" = :1 AND "value"."region_code" = :2;
                """, doBindings: { (statement) in
                    try statement.bind(position: 1, language)
                    try statement.bind(position: 2, reg)
                }, handleRow: { (statement, index) in
                    var key = Key(
                        id: statement.columnInt(position: 0),
                        name: statement.columnText(position: 1),
                        comment: statement.optional(position: 2)
                    )
                    key.values = values(for: key.id, language: language, region: region)
                    keys.append(key)
                })
            default:
                try db.forEachRow(statement: """
                SELECT  "key"."id", "name", "comment"
                FROM "key"
                JOIN "value" ON "key"."id" = "value"."key"
                WHERE "value"."language_code" = :1;
                """, doBindings: { (statement) in
                    try statement.bind(position: 1, language)
                }, handleRow: { (statement, index) in
                    var key = Key(
                        id: statement.columnInt(position: 0),
                        name: statement.columnText(position: 1),
                        comment: statement.optional(position: 2)
                    )
                    key.values = values(for: key.id, language: language, region: region)
                    keys.append(key)
                })
            }
        } catch {
            print(error)
        }
        
        return keys
    }
    
    public func values() -> [Value] {
        var values: [Value] = []
        
        do {
            try db.forEachRow(statement: """
            SELECT "id", "key", "language_code", "region_code", "localization"
            FROM "value";
            """, handleRow: { (statement, index) in
                let value = Value(
                    id: statement.columnInt(position: 0),
                    key: statement.columnInt(position: 1),
                    language: statement.columnText(position: 2),
                    region: statement.optional(position: 3),
                    localization: statement.columnText(position: 4)
                )
                
                values.append(value)
            })
        } catch {
            print(error)
        }
        
        return values
    }
    
    public func value(_ id: Key.ID) -> Value? {
        var value: Value?
        
        do {
            try db.forEachRow(statement: """
            SELECT "id", "key", "language_code", "region_code", "localization"
            FROM "value"
            WHERE "id" = :1
            LIMIT 1;
            """, doBindings: { (statement) in
                try statement.bind(position: 1, id)
            }, handleRow: { (statement, index) in
                value = Value(
                    id: statement.columnInt(position: 0),
                    key: statement.columnInt(position: 1),
                    language: statement.columnText(position: 2),
                    region: statement.optional(position: 3),
                    localization: statement.columnText(position: 4)
                )
            })
        } catch {
            print(error)
        }
        
        return value
    }
    
    public func values(for key: Key.ID, language: LanguageCode?, region: RegionCode?) -> [Value] {
        let _language = (language != nil && !(language!).isEmpty) ? language : nil
        let _region = (region != nil && !(region!).isEmpty) ? region : nil
        
        var values: [Value] = []
        
        do {
            switch (_language, _region) {
            case (.some(let lan), .some(let reg)) where !lan.isEmpty && !reg.isEmpty:
                try db.forEachRow(statement: """
                SELECT "id", "key", "language_code", "region_code", "localization"
                FROM "value"
                WHERE "key" = :1 AND "language_code" = :2 AND "region_code" = :3;
                """, doBindings: { (statement) in
                    try statement.bind(position: 1, key)
                    try statement.bind(position: 2, lan)
                    try statement.bind(position: 3, reg)
                }, handleRow: { (statement, index) in
                    let value = Value(
                        id: statement.columnInt(position: 0),
                        key: statement.columnInt(position: 1),
                        language: statement.columnText(position: 2),
                        region: statement.optional(position: 3),
                        localization: statement.columnText(position: 4)
                    )
                    
                    values.append(value)
                })
            case (.some(let lan), .none) where !lan.isEmpty:
                try db.forEachRow(statement: """
                SELECT "id", "key", "language_code", "region_code", "localization"
                FROM "value"
                WHERE "key" = :1 AND "language_code" = :2;
                """, doBindings: { (statement) in
                    try statement.bind(position: 1, key)
                    try statement.bind(position: 2, lan)
                }, handleRow: { (statement, index) in
                    let value = Value(
                        id: statement.columnInt(position: 0),
                        key: statement.columnInt(position: 1),
                        language: statement.columnText(position: 2),
                        region: statement.optional(position: 3),
                        localization: statement.columnText(position: 4)
                    )
                    
                    values.append(value)
                })
            case (.none, .some(let reg)) where !reg.isEmpty:
                try db.forEachRow(statement: """
                SELECT "id", "key", "language_code", "region_code", "localization"
                FROM "value"
                WHERE "key" = :1 AND "region_code" = :2;
                """, doBindings: { (statement) in
                    try statement.bind(position: 1, key)
                    try statement.bind(position: 2, reg)
                }, handleRow: { (statement, index) in
                    let value = Value(
                        id: statement.columnInt(position: 0),
                        key: statement.columnInt(position: 1),
                        language: statement.columnText(position: 2),
                        region: statement.optional(position: 3),
                        localization: statement.columnText(position: 4)
                    )
                    
                    values.append(value)
                })
            default:
                try db.forEachRow(statement: """
                SELECT "id", "key", "language_code", "region_code", "localization"
                FROM "value"
                WHERE "key" = :1;
                """, doBindings: { (statement) in
                    try statement.bind(position: 1, key)
                }, handleRow: { (statement, index) in
                    let value = Value(
                        id: statement.columnInt(position: 0),
                        key: statement.columnInt(position: 1),
                        language: statement.columnText(position: 2),
                        region: statement.optional(position: 3),
                        localization: statement.columnText(position: 4)
                    )
                    
                    values.append(value)
                })
            }
        } catch {
            print(error)
        }
        
        return values
    }
    
    public func insert(_ key: Key) throws {
        var id: Key.ID = key.id
        
        switch self.key(named: key.name) {
        case .some(let existing):
            id = existing.id
        case .none:
            try db.execute(statement: """
            INSERT INTO "key" ( "name", "comment" )
            VALUES (:1, :2);
            """) { (statement) in
                try statement.bind(position: 1, key.name)
                try statement.bind(position: 2, key.comment ?? "")
            }
            
            id = db.lastInsertRowID()
        }
        
        try key.values.forEach {
            let localization = Value(id: -1, key: id, language: $0.language, region: $0.region ?? "", localization: $0.localization)
            try insert(localization)
        }
    }
    
    public func insert(_ value: Value) throws {
        let existing = self.values(for: value.key, language: value.language, region: value.region)
        guard existing.isEmpty else {
            return
        }
        
        try db.execute(statement: """
        INSERT INTO "value" ("key", "language_code", "region_code", "localization")
        VALUES (:1, :2, :3, :4);
        """, doBindings: { (statement) in
            try statement.bind(position: 1, value.key)
            try statement.bind(position: 2, value.language)
            if let region = value.region, !region.isEmpty {
                try statement.bind(position: 3, region)
            } else {
                try statement.bindNull(position: 3)
            }
            try statement.bind(position: 4, value.localization)
        })
    }
}
