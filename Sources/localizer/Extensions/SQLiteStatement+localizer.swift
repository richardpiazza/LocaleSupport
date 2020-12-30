import Foundation
import Statement
import StatementSQLite

extension SQLiteStatement {
    static var createExpression: Self {
        .init(
            .CREATE(
                .SCHEMA(Expression.self, ifNotExists: true)
            )
        )
    }
    
    static var createTranslation: Self {
        .init(
            .CREATE(
                .SCHEMA(Translation.self, ifNotExists: true)
            )
        )
    }
    
    static var selectAllFromExpression: Self {
        return .init(
            .SELECT(
                .column(Expression.id),
                .column(Expression.name),
                .column(Expression.defaultLanguage),
                .column(Expression.comment),
                .column(Expression.feature)
            ),
            .FROM_TABLE(Expression.self)
        )
    }
    
    static func selectExpressionsWith(languageCode: LanguageCode, regionCode: RegionCode?) -> Self {
        .init(
            .SELECT(
                .column(Expression.id),
                .column(Expression.name),
                .column(Expression.defaultLanguage),
                .column(Expression.comment),
                .column(Expression.feature)
            ),
            .FROM_TABLE(Expression.self),
            .JOIN_TABLE(Translation.self, on: Translation.expressionID, equals: Expression.id),
            .WHERE(
                .AND(
                    .comparison(Translation.language, .equal(languageCode.rawValue)),
                    .unwrap(regionCode, transform: { .comparison(Translation.region, .equal($0.rawValue)) })
                )
            )
        )
    }
    
    static func selectExpression(_ query: Expression.Query) -> Self {
        var id: Expression.ID?
        var name: String?
        
        switch query {
        case .id(let value):
            id = value
        case .name(let value):
            name = value
        }
        
        return .init(
            .SELECT(
                .column(Expression.id),
                .column(Expression.name),
                .column(Expression.defaultLanguage),
                .column(Expression.comment),
                .column(Expression.feature)
            ),
            .FROM_TABLE(Expression.self),
            .WHERE(
                .unwrap(id, transform: { .comparison(Expression.id, .equal($0)) }),
                .unwrap(name, transform: { .comparison(Expression.name, .equal($0)) })
            ),
            .LIMIT(1)
        )
    }
    
    static var selectAllFromTranslation: Self {
        .init(
            .SELECT(
                .column(Translation.id),
                .column(Translation.expressionID),
                .column(Translation.language),
                .column(Translation.region),
                .column(Translation.value)
            ),
            .FROM_TABLE(Translation.self)
        )
    }
    
    static func selectTranslation(_ id: Translation.ID) -> Self {
        .init(
            .SELECT(
                .column(Translation.id),
                .column(Translation.expressionID),
                .column(Translation.language),
                .column(Translation.region),
                .column(Translation.value)
            ),
            .FROM_TABLE(Translation.self),
            .WHERE(
                .comparison(Translation.id, .equal(id))
            ),
            .LIMIT(1)
        )
    }
    
    static func selectTranslationsFor(_ expressionID: Expression.ID, languageCode: LanguageCode?, regionCode: RegionCode?) -> Self {
        .init(
            .SELECT(
                .column(Translation.id),
                .column(Translation.expressionID),
                .column(Translation.language),
                .column(Translation.region),
                .column(Translation.value)
            ),
            .FROM_TABLE(Translation.self),
            .WHERE(
                .AND(
                    .comparison(Translation.expressionID, .equal(expressionID)),
                    .unwrap(languageCode, transform: { .comparison(Translation.language, .equal($0.rawValue)) }),
                    .unwrap(regionCode, transform: { .comparison(Translation.region, .equal($0.rawValue)) }),
                    .if(languageCode != nil && regionCode == nil, .logical(Translation.region, .isNull))
                )
            )
        )
    }
    
    static func insertExpression(_ expression: Expression) -> Self {
        .init(
            .INSERT_INTO_TABLE(
                Expression.self,
                .column(Expression.name),
                .column(Expression.defaultLanguage),
                .column(Expression.comment),
                .column(Expression.feature)
            ),
            .VALUES(
                .value(expression.name),
                .value(expression.defaultLanguage),
                .unwrap(expression.comment, transform: { .value($0) }, else: .value(NSNull())),
                .unwrap(expression.feature, transform: { .value($0) }, else: .value(NSNull()))
            )
        )
    }
    
    static func insertTranslation(_ translation: Translation) -> Self {
        .init(
            .INSERT_INTO_TABLE(
                Translation.self,
                .column(Translation.expressionID),
                .column(Translation.language),
                .column(Translation.region),
                .column(Translation.value)
            ),
            .VALUES(
                .value(translation.expressionID),
                .value(translation.language),
                .unwrap(translation.region, transform: { .value($0) }, else: .value(NSNull())),
                .value(translation.value)
            )
        )
    }
    
    static func updateExpression(_ id: Expression.ID, _ update: Expression.Update) -> Self {
        var name: String?
        var language: String?
        var comment: String?
        var commentNull: Bool = false
        var feature: String?
        var featureNull: Bool = false
        
        switch update {
        case .name(let value):
            name = value
        case .defaultLanguage(let value):
            language = value.rawValue
        case .comment(let value):
            comment = value
            commentNull = (value == nil)
        case .feature(let value):
            feature = value
            featureNull = (value == nil)
        }
        
        return .init(
            .UPDATE_TABLE(Expression.self),
            .SET(
                .unwrap(name, transform: { .value($0) }),
                .unwrap(language, transform: { .value($0) }),
                .unwrap(comment, transform: { .value($0) }),
                .unwrap(feature, transform: { .value($0) }),
                .if(commentNull, .value(NSNull())),
                .if(featureNull, .value(NSNull()))
            ),
            .WHERE(
                .comparison(Expression.id, .equal(id))
            )
        )
    }
    
    static func updateTranslation(_ id: Translation.ID, _ update: Translation.Update) -> Self {
        var expressionID: Expression.ID?
        var language: String?
        var region: String?
        var regionNull: Bool = false
        var value: String?
        
        switch update {
        case .expressionID(let value):
            expressionID = value
        case .language(let value):
            language = value.rawValue
        case .region(let value):
            region = value?.rawValue
            regionNull = (value == nil)
        case .value(let _value):
            value = _value
        }
        
        return .init(
            .UPDATE_TABLE(Translation.self),
            .SET(
                .unwrap(expressionID, transform: { .value($0) }),
                .unwrap(language, transform: { .value($0) }),
                .unwrap(region, transform: { .value($0) }),
                .unwrap(value, transform: { .value($0) }),
                .if(regionNull, .value(NSNull()))
            ),
            .WHERE(
                .comparison(Translation.id, .equal(id))
            )
        )
    }
    
    static func deleteExpression(_ id: Expression.ID) -> Self {
        .init(
            .DELETE_FROM_TABLE(Expression.self),
            .WHERE(
                .comparison(Expression.id, .equal(id))
            ),
            .LIMIT(1)
        )
    }
    
    static func deleteTranslation(_ id: Translation.ID) -> Self {
        .init(
            .DELETE_FROM_TABLE(Translation.self),
            .WHERE(
                .comparison(Translation.id, .equal(id))
            ),
            .LIMIT(1)
        )
    }
}
