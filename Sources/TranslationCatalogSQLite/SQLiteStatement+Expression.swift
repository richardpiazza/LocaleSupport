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
                .SCHEMA(ExpressionEntity.self, ifNotExists: true)
            )
        )
    }
}

// MARK: - Expression (Queries)
extension SQLiteStatement {
    // MARK: Select Expressions
    static var selectAllFromExpression: Self {
        .init(
            .SELECT(
                .column(ExpressionEntity.id),
                .column(ExpressionEntity.uuid),
                .column(ExpressionEntity.key),
                .column(ExpressionEntity.name),
                .column(ExpressionEntity.defaultLanguage),
                .column(ExpressionEntity.context),
                .column(ExpressionEntity.feature)
            ),
            .FROM_TABLE(ExpressionEntity.self)
        )
    }
    
    static func selectExpressions(withProjectID id: Int) -> Self {
        .init(
            .SELECT(
                .column(ExpressionEntity.id),
                .column(ExpressionEntity.uuid),
                .column(ExpressionEntity.key),
                .column(ExpressionEntity.name),
                .column(ExpressionEntity.defaultLanguage),
                .column(ExpressionEntity.context),
                .column(ExpressionEntity.feature)
            ),
            .FROM(
                .TABLE(ExpressionEntity.self),
                .JOIN(ProjectExpressionEntity.self, on: ExpressionEntity.id, equals: ProjectExpressionEntity.expressionID)
            ),
            .WHERE(
                .column(ProjectExpressionEntity.projectID, op: .equal, value: id)
            )
        )
    }
    
    static func selectExpressions(withKeyLike key: String) -> Self {
        .init(
            .SELECT(
                .column(ExpressionEntity.id),
                .column(ExpressionEntity.uuid),
                .column(ExpressionEntity.key),
                .column(ExpressionEntity.name),
                .column(ExpressionEntity.defaultLanguage),
                .column(ExpressionEntity.context),
                .column(ExpressionEntity.feature)
            ),
            .FROM(
                .TABLE(ExpressionEntity.self),
                .JOIN(ProjectExpressionEntity.self, on: ExpressionEntity.id, equals: ProjectExpressionEntity.expressionID)
            ),
            .WHERE(
                .column(ExpressionEntity.key, tablePrefix: true),
                .raw("LIKE"),
                .value("%\(key)%")
            )
        )
    }
    
    static func selectExpressions(withNameLike name: String) -> Self {
        .init(
            .SELECT(
                .column(ExpressionEntity.id),
                .column(ExpressionEntity.uuid),
                .column(ExpressionEntity.key),
                .column(ExpressionEntity.name),
                .column(ExpressionEntity.defaultLanguage),
                .column(ExpressionEntity.context),
                .column(ExpressionEntity.feature)
            ),
            .FROM(
                .TABLE(ExpressionEntity.self),
                .JOIN(ProjectExpressionEntity.self, on: ExpressionEntity.id, equals: ProjectExpressionEntity.expressionID)
            ),
            .WHERE(
                .column(ExpressionEntity.name, tablePrefix: true),
                .raw("LIKE"),
                .value("%\(name)%")
            )
        )
    }
    
    static func selectExpressionsWith(languageCode: LanguageCode, scriptCode: ScriptCode?, regionCode: RegionCode?) -> Self {
        .init(
            .SELECT(
                .column(ExpressionEntity.id),
                .column(ExpressionEntity.uuid),
                .column(ExpressionEntity.key),
                .column(ExpressionEntity.name),
                .column(ExpressionEntity.defaultLanguage),
                .column(ExpressionEntity.context),
                .column(ExpressionEntity.feature)
            ),
            .FROM(
                .TABLE(ExpressionEntity.self),
                .JOIN(TranslationEntity.self, on: TranslationEntity.expressionID, equals: ExpressionEntity.id)
            ),
            .WHERE(
                .AND(
                    .column(TranslationEntity.language, op: .equal, value: languageCode.rawValue),
                    .unwrap(scriptCode, transform: { .column(TranslationEntity.script, op: .equal, value: $0.rawValue) }),
                    .unwrap(regionCode, transform: { .column(TranslationEntity.region, op: .equal, value: $0.rawValue) })
                )
            )
        )
    }
    
    // MARK: Select Expression
    static func selectExpression(withID id: Int) -> Self {
        .init(
            .SELECT(
                .column(ExpressionEntity.id),
                .column(ExpressionEntity.uuid),
                .column(ExpressionEntity.key),
                .column(ExpressionEntity.name),
                .column(ExpressionEntity.defaultLanguage),
                .column(ExpressionEntity.context),
                .column(ExpressionEntity.feature)
            ),
            .FROM_TABLE(ExpressionEntity.self),
            .WHERE(
                .column(ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectExpression(withID id: Expression.ID) -> Self {
        .init(
            .SELECT(
                .column(ExpressionEntity.id),
                .column(ExpressionEntity.uuid),
                .column(ExpressionEntity.key),
                .column(ExpressionEntity.name),
                .column(ExpressionEntity.defaultLanguage),
                .column(ExpressionEntity.context),
                .column(ExpressionEntity.feature)
            ),
            .FROM_TABLE(ExpressionEntity.self),
            .WHERE(
                .column(ExpressionEntity.uuid, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectExpression(withKey key: String) -> Self {
        .init(
            .SELECT(
                .column(ExpressionEntity.id),
                .column(ExpressionEntity.uuid),
                .column(ExpressionEntity.key),
                .column(ExpressionEntity.name),
                .column(ExpressionEntity.defaultLanguage),
                .column(ExpressionEntity.context),
                .column(ExpressionEntity.feature)
            ),
            .FROM_TABLE(ExpressionEntity.self),
            .WHERE(
                .column(ExpressionEntity.key, op: .equal, value: key)
            ),
            .LIMIT(1)
        )
    }
    
    // MARK: Insert Expression
    static func insertExpression(_ expression: ExpressionEntity) -> Self {
        .init(
            .INSERT_INTO(
                ExpressionEntity.self,
                .column(ExpressionEntity.uuid),
                .column(ExpressionEntity.key),
                .column(ExpressionEntity.name),
                .column(ExpressionEntity.defaultLanguage),
                .column(ExpressionEntity.context),
                .column(ExpressionEntity.feature)
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
    
    // MARK: Update Expression
    static func updateExpression(_ id: Int, key: String) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(ExpressionEntity.self)
            ),
            .SET(
                .column(ExpressionEntity.key, op: .equal, value: key)
            ),
            .WHERE(
                .column(ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateExpression(_ id: Int, name: String) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(ExpressionEntity.self)
            ),
            .SET(
                .column(ExpressionEntity.name, op: .equal, value: name)
            ),
            .WHERE(
                .column(ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateExpression(_ id: Int, defaultLanguage: LanguageCode) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(ExpressionEntity.self)
            ),
            .SET(
                .column(ExpressionEntity.defaultLanguage, op: .equal, value: defaultLanguage.rawValue)
            ),
            .WHERE(
                .column(ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateExpression(_ id: Int, context: String?) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(ExpressionEntity.self)
            ),
            .SET(
                .if(
                    (context != nil && !context!.isEmpty),
                    .column(ExpressionEntity.context, op: .equal, value: context!),
                    else: .column(ExpressionEntity.context, op: .equal, value: NSNull())
                )
            ),
            .WHERE(
                .column(ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func updateExpression(_ id: Int, feature: String?) -> Self {
        SQLiteStatement(
            .UPDATE(
                .TABLE(ExpressionEntity.self)
            ),
            .SET(
                .if(
                    (feature != nil && !feature!.isEmpty),
                    .column(ExpressionEntity.feature, op: .equal, value: feature!),
                    else: .column(ExpressionEntity.feature, op: .equal, value: NSNull())
                )
            ),
            .WHERE(
                .column(ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    // MARK: Delete Expression
    static func deleteExpression(_ id: Int) -> Self {
        .init(
            .DELETE_FROM(ExpressionEntity.self),
            .WHERE(
                .column(ExpressionEntity.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
}
