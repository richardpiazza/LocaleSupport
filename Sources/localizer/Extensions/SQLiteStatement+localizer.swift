import Foundation
import Statement
import StatementSQLite
import LocaleSupport

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
    
    static func selectExpressionsWith(languageCode: LanguageCode, scriptCode: ScriptCode?, regionCode: RegionCode?) -> Self {
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
                    .column(Translation.language, op: .equal, value: languageCode.rawValue),
                    .unwrap(scriptCode, transform: { .column(Translation.script, op: .equal, value: $0.rawValue) }),
                    .unwrap(regionCode, transform: { .column(Translation.region, op: .equal, value: $0.rawValue) })
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
                .unwrap(id, transform: { .column(Expression.id, op: .equal, value: $0) }),
                .unwrap(name, transform: { .column(Expression.name, op: .equal, value: $0) })
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
                .column(Translation.value),
                .column(Translation.script)
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
                .column(Translation.value),
                .column(Translation.script)
            ),
            .FROM_TABLE(Translation.self),
            .WHERE(
                .column(Translation.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func selectTranslationsFor(_ expressionID: Expression.ID, languageCode: LanguageCode?, scriptCode: ScriptCode?, regionCode: RegionCode?) -> Self {
        .init(
            .SELECT(
                .column(Translation.id),
                .column(Translation.expressionID),
                .column(Translation.language),
                .column(Translation.region),
                .column(Translation.value),
                .column(Translation.script)
            ),
            .FROM_TABLE(Translation.self),
            .WHERE(
                .AND(
                    .column(Translation.expressionID, op: .equal, value: expressionID),
                    .unwrap(languageCode, transform: { .column(Translation.language, op: .equal, value: $0.rawValue) }),
                    .unwrap(scriptCode, transform: { .column(Translation.script, op: .equal, value: $0.rawValue) }),
                    .unwrap(regionCode, transform: { .column(Translation.region, op: .equal, value: $0.rawValue) }),
                    .if(languageCode != nil && regionCode == nil, .column(Translation.region, op: .equal, value: NSNull())),
                    .if(languageCode != nil && scriptCode == nil, .column(Translation.script, op: .equal, value: NSNull()))
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
                .column(Translation.value),
                .column(Translation.script)
            ),
            .VALUES(
                .value(translation.expressionID),
                .value(translation.language),
                .unwrap(translation.region, transform: { .value($0) }, else: .value(NSNull())),
                .value(translation.value),
                .unwrap(translation.script, transform: { .value($0) }, else: .value(NSNull()))
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
                .column(Expression.id, op: .equal, value: id)
            )
        )
    }
    
    static func updateTranslation(_ id: Translation.ID, _ update: Translation.Update) -> Self {
        var expressionID: Expression.ID?
        var language: String?
        var script: String?
        var scriptNull: Bool = false
        var region: String?
        var regionNull: Bool = false
        var value: String?
        
        switch update {
        case .expressionID(let value):
            expressionID = value
        case .language(let value):
            language = value.rawValue
        case .script(let value):
            script = value?.rawValue
            scriptNull = (value == nil)
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
                .unwrap(script, transform: { .value($0) }),
                .unwrap(region, transform: { .value($0) }),
                .unwrap(value, transform: { .value($0) }),
                .if(scriptNull, .value(NSNull())),
                .if(regionNull, .value(NSNull()))
            ),
            .WHERE(
                .column(Translation.id, op: .equal, value: id)
            )
        )
    }
    
    static func deleteExpression(_ id: Expression.ID) -> Self {
        .init(
            .DELETE_FROM_TABLE(Expression.self),
            .WHERE(
                .column(Expression.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static func deleteTranslation(_ id: Translation.ID) -> Self {
        .init(
            .DELETE_FROM_TABLE(Translation.self),
            .WHERE(
                .column(Translation.id, op: .equal, value: id)
            ),
            .LIMIT(1)
        )
    }
    
    static var translationTable_addScriptCode: Self {
        .init(
            .ALTER_TABLE(
                Translation.self,
                .ADD_COLUMN(Translation.script)
            )
        )
    }
}
