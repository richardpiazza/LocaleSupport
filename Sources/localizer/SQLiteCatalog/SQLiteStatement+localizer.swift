import Foundation
import Statement
import StatementSQLite
import LocaleSupport
import TranslationCatalog

// MARK: - Project
extension SQLiteStatement {
    // MARK: Schema
    static var createProjectEntity: Self {
        .init(
            .CREATE(
                .SCHEMA(SQLiteCatalog.ProjectEntity.self, ifNotExists: true)
            )
        )
    }
}

// MARK: - ProjectExpression
extension SQLiteStatement {
    // MARK: Schema
    static var createProjectExpressionEntity: Self {
        .init(
            .CREATE(
                .SCHEMA(SQLiteCatalog.ProjectExpressionEntity.self, ifNotExists: true)
            )
        )
    }
}

// MARK: - Expression
extension SQLiteStatement {
    // MARK: Schema
    static var createExpressionEntity: Self {
        .init(
            .CREATE(
                .SCHEMA(SQLiteCatalog.ExpressionEntity.self, ifNotExists: true)
            )
        )
    }
    
    // MARK: Queries
    static var selectAllFromExpression: Self {
        return .init(
            .SELECT(
                .column(SQLiteCatalog.ExpressionEntity.id),
                .column(SQLiteCatalog.ExpressionEntity.uuid),
                .column(SQLiteCatalog.ExpressionEntity.key),
                .column(SQLiteCatalog.ExpressionEntity.name),
                .column(SQLiteCatalog.ExpressionEntity.defaultLanguage),
                .column(SQLiteCatalog.ExpressionEntity.context),
                .column(SQLiteCatalog.ExpressionEntity.feature)
            ),
            .FROM_TABLE(SQLiteCatalog.ExpressionEntity.self)
        )
    }
    
    static func selectExpression(withID id: Int) -> Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.ExpressionEntity.id),
                .column(SQLiteCatalog.ExpressionEntity.uuid),
                .column(SQLiteCatalog.ExpressionEntity.key),
                .column(SQLiteCatalog.ExpressionEntity.name),
                .column(SQLiteCatalog.ExpressionEntity.defaultLanguage),
                .column(SQLiteCatalog.ExpressionEntity.context),
                .column(SQLiteCatalog.ExpressionEntity.feature)
            ),
            .FROM_TABLE(SQLiteCatalog.ExpressionEntity.self),
            .WHERE(
                .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectExpression(withID id: Expression.ID) -> Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.ExpressionEntity.id),
                .column(SQLiteCatalog.ExpressionEntity.uuid),
                .column(SQLiteCatalog.ExpressionEntity.key),
                .column(SQLiteCatalog.ExpressionEntity.name),
                .column(SQLiteCatalog.ExpressionEntity.defaultLanguage),
                .column(SQLiteCatalog.ExpressionEntity.context),
                .column(SQLiteCatalog.ExpressionEntity.feature)
            ),
            .FROM_TABLE(SQLiteCatalog.ExpressionEntity.self),
            .WHERE(
                .column(SQLiteCatalog.ExpressionEntity.uuid, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectExpression(withKey key: String) -> Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.ExpressionEntity.id),
                .column(SQLiteCatalog.ExpressionEntity.uuid),
                .column(SQLiteCatalog.ExpressionEntity.key),
                .column(SQLiteCatalog.ExpressionEntity.name),
                .column(SQLiteCatalog.ExpressionEntity.defaultLanguage),
                .column(SQLiteCatalog.ExpressionEntity.context),
                .column(SQLiteCatalog.ExpressionEntity.feature)
            ),
            .FROM_TABLE(SQLiteCatalog.ExpressionEntity.self),
            .WHERE(
                .column(SQLiteCatalog.ExpressionEntity.key, op: .equal, value: key)
            ),
            .LIMIT(1)
        )
    }
    
    static func insertExpression(_ expression: SQLiteCatalog.ExpressionEntity) -> Self {
        .init(
            .INSERT_INTO(
                SQLiteCatalog.ExpressionEntity.self,
                .column(SQLiteCatalog.ExpressionEntity.uuid),
                .column(SQLiteCatalog.ExpressionEntity.key),
                .column(SQLiteCatalog.ExpressionEntity.name),
                .column(SQLiteCatalog.ExpressionEntity.defaultLanguage),
                .column(SQLiteCatalog.ExpressionEntity.context),
                .column(SQLiteCatalog.ExpressionEntity.feature)
            ),
            .VALUES(
                .value(expression.uuid),
                .value(expression.key),
                .value(expression.name),
                .value(expression.defaultLanguage),
                .unwrap(expression.context, transform: { .value($0) }, else: .value(NSNull())),
                .unwrap(expression.feature, transform: { .value($0) }, else: .value(NSNull()))
            )
        )
    }
    
    static func deleteExpression(_ id: Int) -> Self {
        .init(
            .DELETE_FROM(SQLiteCatalog.ExpressionEntity.self),
            .WHERE(
                .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateExpression(_ id: Int, _ update: SQLiteCatalog.ExpressionUpdate) -> Self {
        switch update {
        case .key(let value):
            return .init(
                .UPDATE_TABLE(SQLiteCatalog.ExpressionEntity.self),
                .SET(
                    .column(SQLiteCatalog.ExpressionEntity.key, op: .equal, value: value)
                ),
                .WHERE(
                    .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
                )
            )
        case .name(let value):
            return .init(
                .UPDATE_TABLE(SQLiteCatalog.ExpressionEntity.self),
                .SET(
                    .column(SQLiteCatalog.ExpressionEntity.name, op: .equal, value: value)
                ),
                .WHERE(
                    .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
                )
            )
        case .defaultLanguage(let value):
            return .init(
                .UPDATE_TABLE(SQLiteCatalog.ExpressionEntity.self),
                .SET(
                    .column(SQLiteCatalog.ExpressionEntity.defaultLanguage, op: .equal, value: value.rawValue)
                ),
                .WHERE(
                    .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
                )
            )
        case .context(let value):
            if let value = value {
                return .init(
                    .UPDATE_TABLE(SQLiteCatalog.ExpressionEntity.self),
                    .SET(
                        .column(SQLiteCatalog.ExpressionEntity.context, op: .equal, value: value)
                    ),
                    .WHERE(
                        .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
                    )
                )
            } else {
                return .init(
                    .UPDATE_TABLE(SQLiteCatalog.ExpressionEntity.self),
                    .SET(
                        .column(SQLiteCatalog.ExpressionEntity.context, op: .equal, value: NSNull())
                    ),
                    .WHERE(
                        .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
                    )
                )
            }
        case .feature(let value):
            if let value = value {
                return .init(
                    .UPDATE_TABLE(SQLiteCatalog.ExpressionEntity.self),
                    .SET(
                        .column(SQLiteCatalog.ExpressionEntity.feature, op: .equal, value: value)
                    ),
                    .WHERE(
                        .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
                    )
                )
            } else {
                return .init(
                    .UPDATE_TABLE(SQLiteCatalog.ExpressionEntity.self),
                    .SET(
                        .column(SQLiteCatalog.ExpressionEntity.feature, op: .equal, value: NSNull())
                    ),
                    .WHERE(
                        .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
                    )
                )
            }
        }
    }
}

// MARK: - Translation
extension SQLiteStatement {
    // MARK: Schema
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
    
    // MARK: Queries
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
    
    static func updateTranslation(_ id: Int, _ update: SQLiteCatalog.TranslationUpdate) -> Self {
        switch update {
        case .language(let languageCode):
            return .init(
                .UPDATE_TABLE(SQLiteCatalog.TranslationEntity.self),
                .SET(
                    .column(SQLiteCatalog.TranslationEntity.language, op: .equal, value: languageCode.rawValue)
                ),
                .WHERE(
                    .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
                )
            )
        case .script(let scriptCode):
            if let scriptCode = scriptCode {
                return .init(
                    .UPDATE_TABLE(SQLiteCatalog.TranslationEntity.self),
                    .SET(
                        .column(SQLiteCatalog.TranslationEntity.script, op: .equal, value: scriptCode.rawValue)
                    ),
                    .WHERE(
                        .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
                    )
                )
            } else {
                return .init(
                    .UPDATE_TABLE(SQLiteCatalog.TranslationEntity.self),
                    .SET(
                        .column(SQLiteCatalog.TranslationEntity.script, op: .equal, value: NSNull())
                    ),
                    .WHERE(
                        .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
                    )
                )
            }
        case .region(let regionCode):
            if let regionCode = regionCode {
                return .init(
                    .UPDATE_TABLE(SQLiteCatalog.TranslationEntity.self),
                    .SET(
                        .column(SQLiteCatalog.TranslationEntity.region, op: .equal, value: regionCode.rawValue)
                    ),
                    .WHERE(
                        .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
                    )
                )
            } else {
                return .init(
                    .UPDATE_TABLE(SQLiteCatalog.TranslationEntity.self),
                    .SET(
                        .column(SQLiteCatalog.TranslationEntity.region, op: .equal, value: NSNull())
                    ),
                    .WHERE(
                        .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
                    )
                )
            }
        case .value(let value):
            return .init(
                .UPDATE_TABLE(SQLiteCatalog.TranslationEntity.self),
                .SET(
                    .column(SQLiteCatalog.TranslationEntity.value, op: .equal, value: value)
                ),
                .WHERE(
                    .column(SQLiteCatalog.TranslationEntity.id, op: .equal, value: id)
                )
            )
        }
    }
}

extension SQLiteStatement {
    static func selectExpressionsWith(languageCode: LanguageCode, scriptCode: ScriptCode?, regionCode: RegionCode?) -> Self {
        .init(
            .SELECT(
                .column(SQLiteCatalog.ExpressionEntity.id),
                .column(SQLiteCatalog.ExpressionEntity.uuid),
                .column(SQLiteCatalog.ExpressionEntity.key),
                .column(SQLiteCatalog.ExpressionEntity.name),
                .column(SQLiteCatalog.ExpressionEntity.defaultLanguage),
                .column(SQLiteCatalog.ExpressionEntity.context),
                .column(SQLiteCatalog.ExpressionEntity.feature)
            ),
            .FROM(
                .TABLE(SQLiteCatalog.ExpressionEntity.self),
                .JOIN(SQLiteCatalog.TranslationEntity.self, on: SQLiteCatalog.TranslationEntity.expressionID, equals: SQLiteCatalog.ExpressionEntity.id)
            ),
            .WHERE(
                .AND(
                    .column(SQLiteCatalog.TranslationEntity.language, op: .equal, value: languageCode.rawValue),
                    .unwrap(scriptCode, transform: { .column(SQLiteCatalog.TranslationEntity.script, op: .equal, value: $0.rawValue) }),
                    .unwrap(regionCode, transform: { .column(SQLiteCatalog.TranslationEntity.region, op: .equal, value: $0.rawValue) })
                )
            )
        )
    }
}
