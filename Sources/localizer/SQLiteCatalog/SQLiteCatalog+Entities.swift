import Foundation
import PerfectSQLite
import Statement
import StatementSQLite
import LocaleSupport
import TranslationCatalog

internal extension SQLiteCatalog {
    struct ProjectEntity: Table, Identifiable {
        
        enum CodingKeys: String, CodingKey {
            case id
            case uuid
            case name
        }
        
        static var schema: Schema = { ProjectEntity().schema }()
        static var id: AnyColumn { schema.columns[0] }
        static var uuid: AnyColumn { schema.columns[1] }
        static var name: AnyColumn { schema.columns[2] }
        private var schema: Schema { Schema(name: "project", columns: [_id, _uuid, _name]) }
        
        @Column(table: ProjectEntity.self, name: CodingKeys.id.rawValue, dataType: "INTEGER", notNull: true, unique: true, primaryKey: true, autoIncrement: true)
        var id: Int = 0
        @Column(table: ProjectEntity.self, name: CodingKeys.uuid.rawValue, dataType: "TEXT", notNull: true)
        var uuid: String = ""
        @Column(table: ProjectEntity.self, name: CodingKeys.name.rawValue, dataType: "TEXT", notNull: true)
        var name: String = ""
    }
    
    struct ProjectExpressionEntity: Table {
        
        enum CodingKeys: String, CodingKey {
            case projectID = "project_id"
            case expressionID = "expression_id"
        }
        
        static var schema: Schema = { ProjectExpressionEntity().schema }()
        static var projectID: AnyColumn { schema.columns[0] }
        static var expressionID: AnyColumn { schema.columns[1] }
        private var schema: Schema { Schema(name: "project_expression", columns: [_projectID, _expressionID]) }
        
        @Column(table: ProjectExpressionEntity.self, name: CodingKeys.projectID.rawValue, dataType: "INTEGER", notNull: true, foreignKey: ProjectEntity.id)
        var projectID: Int = 0
        @Column(table: ProjectExpressionEntity.self, name: CodingKeys.expressionID.rawValue, dataType: "INTEGER", notNull: true, foreignKey: ExpressionEntity.id)
        var expressionID: Int = 0
    }
    
    struct ExpressionEntity: Table {
        
        enum CodingKeys: String, CodingKey {
            case id
            case uuid
            case key
            case name
            case defaultLanguage = "default_language"
            case context
            case feature
        }
        
        static var schema: Schema = { ExpressionEntity().schema }()
        static var id: AnyColumn { schema.columns[0] }
        static var uuid: AnyColumn { schema.columns[1] }
        static var key: AnyColumn { schema.columns[2] }
        static var name: AnyColumn { schema.columns[3] }
        static var defaultLanguage: AnyColumn { schema.columns[4] }
        static var context: AnyColumn { schema.columns[5] }
        static var feature: AnyColumn { schema.columns[6] }
        private var schema: Schema { Schema(name: "expression", columns: [_id, _uuid, _key, _name, _defaultLanguage, _context, _feature]) }
        
        @Column(table: ExpressionEntity.self, name: CodingKeys.id.rawValue, dataType: "INTEGER", notNull: true, unique: true, primaryKey: true, autoIncrement: true)
        var id: Int = 0
        @Column(table: ExpressionEntity.self, name: CodingKeys.uuid.rawValue, dataType: "TEXT", notNull: true)
        var uuid: String = ""
        @Column(table: ExpressionEntity.self, name: CodingKeys.key.rawValue, dataType: "TEXT", notNull: true)
        var key: String = ""
        @Column(table: ExpressionEntity.self, name: CodingKeys.name.rawValue, dataType: "TEXT", notNull: true)
        var name: String = ""
        @Column(table: ExpressionEntity.self, name: CodingKeys.defaultLanguage.rawValue, dataType: "TEXT", notNull: true)
        var defaultLanguage: String = ""
        @Column(table: ExpressionEntity.self, name: CodingKeys.context.rawValue, dataType: "TEXT")
        var context: String? = nil
        @Column(table: ExpressionEntity.self, name: CodingKeys.feature.rawValue, dataType: "TEXT")
        var feature: String? = nil
    }
    
    struct TranslationEntity: Table {
        
        enum CodingKeys: String, CodingKey {
            case id
            case uuid
            case expressionID = "expression_id"
            case language = "language_code"
            case script = "script_code"
            case region = "region_code"
            case value
        }
        
        static var schema: Schema = { TranslationEntity().schema }()
        static var id: AnyColumn { schema.columns[0] }
        static var uuid: AnyColumn { schema.columns[1] }
        static var expressionID: AnyColumn { schema.columns[2] }
        static var language: AnyColumn { schema.columns[3] }
        static var script: AnyColumn { schema.columns[4] }
        static var region: AnyColumn { schema.columns[5] }
        static var value: AnyColumn { schema.columns[6] }
        private var schema: Schema { Schema(name: "translation", columns: [_id, _uuid, _expressionID, _language, _script, _region, _value]) }
        
        @Column(table: TranslationEntity.self, name: CodingKeys.id.rawValue, dataType: "INTEGER", notNull: true, unique: true, primaryKey: true, autoIncrement: true)
        var id: Int = 0
        @Column(table: TranslationEntity.self, name: CodingKeys.uuid.rawValue, dataType: "TEXT", notNull: true)
        var uuid: String = ""
        @Column(table: TranslationEntity.self, name: CodingKeys.expressionID.rawValue, dataType: "INTEGER", notNull: true, foreignKey: ExpressionEntity.id)
        var expressionID: Int = 0
        @Column(table: TranslationEntity.self, name: CodingKeys.language.rawValue, dataType: "TEXT", notNull: true)
        var language: String = ""
        @Column(table: TranslationEntity.self, name: CodingKeys.script.rawValue, dataType: "TEXT")
        var script: String? = nil
        @Column(table: TranslationEntity.self, name: CodingKeys.region.rawValue, dataType: "TEXT")
        var region: String? = nil
        @Column(table: TranslationEntity.self, name: CodingKeys.script.rawValue, dataType: "TEXT", notNull: true)
        var value: String = ""
    }
}

extension SQLiteCatalog.ProjectEntity {
    init(_ project: Project) {
        uuid = project.uuid.uuidString
        name = project.name
    }
}

extension Project {
    init?(_ project: SQLiteCatalog.ProjectEntity, expressions: [SQLiteCatalog.ExpressionEntity]) {
        guard let primaryKey = UUID(uuidString: project.uuid) else {
            return nil
        }
        
        self.init(uuid: primaryKey, name: project.name, expressions: expressions.compactMap({ Expression($0) }))
    }
}

extension SQLiteCatalog.ExpressionEntity {
    init(_ expression: Expression) {
        uuid = expression.uuid.uuidString
        key = expression.key
        name = expression.name
        defaultLanguage = expression.defaultLanguage.rawValue
        context = expression.context
        feature = expression.feature
    }
}

extension Expression {
    init?(_ expression: SQLiteCatalog.ExpressionEntity, translations: [SQLiteCatalog.TranslationEntity] = []) {
        guard let primaryKey = UUID(uuidString: expression.uuid) else {
            return nil
        }
        guard let language = LanguageCode(rawValue: expression.defaultLanguage) else {
            return nil
        }
        
        self.init(
            uuid: primaryKey,
            key: expression.key,
            name: expression.name,
            defaultLanguage: language,
            context: expression.context,
            feature: expression.feature,
            translations: translations.compactMap({ TranslationCatalog.Translation($0, expressionUUID: expression.uuid) })
        )
    }
}

extension SQLiteCatalog.TranslationEntity {
    init(_ translation: TranslationCatalog.Translation) {
        uuid = translation.uuid.uuidString
        language = translation.languageCode.rawValue
        script = translation.scriptCode?.rawValue
        region = translation.regionCode?.rawValue
        value = translation.value
    }
}

extension TranslationCatalog.Translation {
    init?(_ translation: SQLiteCatalog.TranslationEntity, expressionUUID: String) {
        guard let primaryKey = UUID(uuidString: translation.uuid) else {
            return nil
        }
        
        guard let foreignKey = UUID(uuidString: expressionUUID) else {
            return nil
        }
        
        guard let language = LanguageCode(rawValue: translation.language) else {
            return nil
        }
        
        let scriptCode: ScriptCode?
        if let script = translation.script {
            guard let code = ScriptCode(rawValue: script) else {
                return nil
            }
            scriptCode = code
        } else {
            scriptCode = nil
        }
        
        let regionCode: RegionCode?
        if let region = translation.region {
            guard let code = RegionCode(rawValue: region) else {
                return nil
            }
            regionCode = code
        } else {
            regionCode = nil
        }
        
        self.init(uuid: primaryKey, expressionID: foreignKey, languageCode: language, scriptCode: scriptCode, regionCode: regionCode, value: translation.value)
    }
}
