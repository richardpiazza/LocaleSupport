import Statement
import StatementSQLite
import TranslationCatalog
import LocaleSupport
import Foundation

// MARK: - Expression (Schema)
extension SQLiteStatement {
    static var createExpressionEntity: Self {
        .init(
            .CREATE(
                .SCHEMA(SQLiteCatalog.ExpressionEntity.self, ifNotExists: true)
            )
        )
    }
}

// MARK: - Expression (Queries)
extension SQLiteStatement {
    static var selectAllFromExpression: Self {
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
            .FROM_TABLE(SQLiteCatalog.ExpressionEntity.self)
        )
    }
    
    static func selectExpressions(withProjectID id: Int) -> Self {
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
                .JOIN(SQLiteCatalog.ProjectExpressionEntity.self, on: SQLiteCatalog.ExpressionEntity.id, equals: SQLiteCatalog.ProjectExpressionEntity.expressionID)
            ),
            .WHERE(
                .column(SQLiteCatalog.ProjectExpressionEntity.projectID, op: .equal, value: id)
            )
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
    
    static func updateExpression(_ id: Int, key: String) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(SQLiteCatalog.ExpressionEntity.self)
            ),
            .SET(
                .column(SQLiteCatalog.ExpressionEntity.key, op: .equal, value: key)
            ),
            .WHERE(
                .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateExpression(_ id: Int, name: String) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(SQLiteCatalog.ExpressionEntity.self)
            ),
            .SET(
                .column(SQLiteCatalog.ExpressionEntity.name, op: .equal, value: name)
            ),
            .WHERE(
                .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateExpression(_ id: Int, defaultLanguage: LanguageCode) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(SQLiteCatalog.ExpressionEntity.self)
            ),
            .SET(
                .column(SQLiteCatalog.ExpressionEntity.defaultLanguage, op: .equal, value: defaultLanguage.rawValue)
            ),
            .WHERE(
                .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateExpression(_ id: Int, context: String?) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(SQLiteCatalog.ExpressionEntity.self)
            ),
            .SET(
                .if(
                    (context != nil && !context!.isEmpty),
                    .column(SQLiteCatalog.ExpressionEntity.context, op: .equal, value: context!),
                    else: .column(SQLiteCatalog.ExpressionEntity.context, op: .equal, value: NSNull())
                )
            ),
            .WHERE(
                .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateExpression(_ id: Int, feature: String?) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(SQLiteCatalog.ExpressionEntity.self)
            ),
            .SET(
                .if(
                    (feature != nil && !feature!.isEmpty),
                    .column(SQLiteCatalog.ExpressionEntity.feature, op: .equal, value: feature!),
                    else: .column(SQLiteCatalog.ExpressionEntity.feature, op: .equal, value: NSNull())
                )
            ),
            .WHERE(
                .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
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
    
    static func deleteExpression(_ id: Int) -> Self {
        .init(
            .DELETE_FROM(SQLiteCatalog.ExpressionEntity.self),
            .WHERE(
                .column(SQLiteCatalog.ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
}
