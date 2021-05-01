import Statement
import StatementSQLite
import TranslationCatalog
import LocaleSupport
import Foundation

// MARK: - Translation (Schema)
extension SQLiteStatement {
    static var createTranslationEntity: Self {
        .init(
            .CREATE(
                .SCHEMA(SQLiteCatalog.TranslationEntity.self, ifNotExists: true)
            )
        )
    }
    
    static var translationTable_addScriptCode: Self {
        .init(
            .ALTER_TABLE(
                SQLiteCatalog.TranslationEntity.self,
                .ADD_COLUMN(SQLiteCatalog.TranslationEntity.script)
            )
        )
    }
    
    static var translationTable_addUUID: Self {
        .init(
            .ALTER_TABLE(SQLiteCatalog.TranslationEntity.self, .ADD_COLUMN(SQLiteCatalog.TranslationEntity.uuid))
        )
    }
}

// MARK: - Translation (Queries)
extension SQLiteStatement {
    static var selectAllFromTranslation: Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.TranslationEntity.id),
                .column(SQLiteCatalog.TranslationEntity.uuid),
                .column(SQLiteCatalog.TranslationEntity.expressionID),
                .column(SQLiteCatalog.TranslationEntity.language),
                .column(SQLiteCatalog.TranslationEntity.script),
                .column(SQLiteCatalog.TranslationEntity.region),
                .column(SQLiteCatalog.TranslationEntity.value)
            ),
            .FROM_TABLE(SQLiteCatalog.TranslationEntity.self)
        )
    }
    
    static func selectTranslation(_ id: Int) -> Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.TranslationEntity.id),
                .column(SQLiteCatalog.TranslationEntity.uuid),
                .column(SQLiteCatalog.TranslationEntity.expressionID),
                .column(SQLiteCatalog.TranslationEntity.language),
                .column(SQLiteCatalog.TranslationEntity.script),
                .column(SQLiteCatalog.TranslationEntity.region),
                .column(SQLiteCatalog.TranslationEntity.value)
            ),
            .FROM_TABLE(SQLiteCatalog.TranslationEntity.self),
            .WHERE(
                .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectTranslation(_ id: TranslationCatalog.Translation.ID) -> Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.TranslationEntity.id),
                .column(SQLiteCatalog.TranslationEntity.uuid),
                .column(SQLiteCatalog.TranslationEntity.expressionID),
                .column(SQLiteCatalog.TranslationEntity.language),
                .column(SQLiteCatalog.TranslationEntity.script),
                .column(SQLiteCatalog.TranslationEntity.region),
                .column(SQLiteCatalog.TranslationEntity.value)
            ),
            .FROM_TABLE(SQLiteCatalog.TranslationEntity.self),
            .WHERE(
                .column(SQLiteCatalog.TranslationEntity.uuid, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectTranslationsFor(_ expressionID: Int) -> Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.TranslationEntity.id),
                .column(SQLiteCatalog.TranslationEntity.uuid),
                .column(SQLiteCatalog.TranslationEntity.expressionID),
                .column(SQLiteCatalog.TranslationEntity.language),
                .column(SQLiteCatalog.TranslationEntity.script),
                .column(SQLiteCatalog.TranslationEntity.region),
                .column(SQLiteCatalog.TranslationEntity.value)
            ),
            .FROM_TABLE(SQLiteCatalog.TranslationEntity.self),
            .WHERE(
                .AND(
                    .column(SQLiteCatalog.TranslationEntity.expressionID, op: .equal, value: expressionID)
                )
            )
        )
    }
    
    static func selectTranslationsFor(_ expressionID: Expression.ID, languageCode: LanguageCode?, scriptCode: ScriptCode?, regionCode: RegionCode?) -> Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.TranslationEntity.id),
                .column(SQLiteCatalog.TranslationEntity.uuid),
                .column(SQLiteCatalog.TranslationEntity.expressionID),
                .column(SQLiteCatalog.TranslationEntity.language),
                .column(SQLiteCatalog.TranslationEntity.script),
                .column(SQLiteCatalog.TranslationEntity.region),
                .column(SQLiteCatalog.TranslationEntity.value)
            ),
            .FROM_TABLE(SQLiteCatalog.TranslationEntity.self),
            .WHERE(
                .AND(
                    .column(SQLiteCatalog.TranslationEntity.expressionID, op: .equal, value: expressionID),
                    .unwrap(languageCode, transform: { .column(SQLiteCatalog.TranslationEntity.language, op: .equal, value: $0.rawValue) }),
                    .unwrap(scriptCode, transform: { .column(SQLiteCatalog.TranslationEntity.script, op: .equal, value: $0.rawValue) }),
                    .unwrap(regionCode, transform: { .column(SQLiteCatalog.TranslationEntity.region, op: .equal, value: $0.rawValue) }),
                    .if(languageCode != nil && regionCode == nil, .column(SQLiteCatalog.TranslationEntity.region, op: .equal, value: NSNull())),
                    .if(languageCode != nil && scriptCode == nil, .column(SQLiteCatalog.TranslationEntity.script, op: .equal, value: NSNull()))
                )
            )
        )
    }
    
    static func insertTranslation(_ translation: SQLiteCatalog.TranslationEntity) -> Self {
        .init(
            .INSERT_INTO(
                SQLiteCatalog.TranslationEntity.self,
                .column(SQLiteCatalog.TranslationEntity.uuid),
                .column(SQLiteCatalog.TranslationEntity.expressionID),
                .column(SQLiteCatalog.TranslationEntity.language),
                .column(SQLiteCatalog.TranslationEntity.region),
                .column(SQLiteCatalog.TranslationEntity.value),
                .column(SQLiteCatalog.TranslationEntity.script)
            ),
            .VALUES(
                .value(translation.uuid),
                .value(translation.expressionID),
                .value(translation.language),
                .unwrap(translation.region, transform: { .value($0) }, else: .value(NSNull())),
                .value(translation.value),
                .unwrap(translation.script, transform: { .value($0) }, else: .value(NSNull()))
            )
        )
    }
    
    static func updateTranslation(_ id: Int, languageCode: LanguageCode) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(SQLiteCatalog.TranslationEntity.self)
            ),
            .SET(
                .column(SQLiteCatalog.TranslationEntity.language, op: .equal, value: languageCode.rawValue)
            ),
            .WHERE(
                .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateTranslation(_ id: Int, scriptCode: ScriptCode?) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(SQLiteCatalog.TranslationEntity.self)
            ),
            .SET(
                .if(
                    (scriptCode != nil),
                    .column(SQLiteCatalog.TranslationEntity.script, op: .equal, value: scriptCode!.rawValue),
                    else: .column(SQLiteCatalog.TranslationEntity.script, op: .equal, value: NSNull())
                )
            ),
            .WHERE(
                .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateTranslation(_ id: Int, regionCode: RegionCode?) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(SQLiteCatalog.TranslationEntity.self)
            ),
            .SET(
                .if(
                    (regionCode != nil),
                    .column(SQLiteCatalog.TranslationEntity.region, op: .equal, value: regionCode!.rawValue),
                    else: .column(SQLiteCatalog.TranslationEntity.region, op: .equal, value: NSNull())
                )
            ),
            .WHERE(
                .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateTranslation(_ id: Int, value: String) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(SQLiteCatalog.TranslationEntity.self)
            ),
            .SET(
                .column(SQLiteCatalog.TranslationEntity.value, op: .equal, value: value)
            ),
            .WHERE(
                .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func deleteTranslation(_ id: Int) -> Self {
        .init(
            .DELETE_FROM(SQLiteCatalog.TranslationEntity.self),
            .WHERE(
                .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func deleteTranslations(withExpressionID id: Int) -> Self {
        .init(
            .DELETE_FROM(SQLiteCatalog.TranslationEntity.self),
            .WHERE(
                .column(SQLiteCatalog.TranslationEntity.expressionID, op: .equal, value: id)
            )
        )
    }
}
