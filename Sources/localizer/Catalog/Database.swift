import Foundation

public protocol Database {
    func expressions(includeTranslations: Bool) throws -> [Expression]
    func expression(_ id: Expression.ID) throws -> Expression
    func expression(named name: String) throws -> Expression
    func expressions(having language: LanguageCode, region: RegionCode?) throws -> [Expression]
    
    func translations() throws -> [Translation]
    func translation(_ id: Translation.ID) throws -> Translation
    func translations(for expressionID: Expression.ID, language: LanguageCode?, region: RegionCode?) throws -> [Translation]
    
    @discardableResult
    func insertExpression(_ expression: Expression) throws -> Expression.ID
    @discardableResult
    func insertTranslation(_ translation: Translation) throws -> Translation.ID
    
    func updateExpression(_ id: Expression.ID, _ update: Expression.Update) throws
    func updateTranslation(_ id: Translation.ID, _ update: Translation.Update) throws
    
    func deleteExpression(_ id: Expression.ID) throws
    func deleteTranslation(_ id: Translation.ID) throws
}

public extension Database {
    func expressions() throws -> [Expression] {
        return try expressions(includeTranslations: false)
    }
    
    func translations(for expressionID: Expression.ID) throws -> [Translation] {
        return try translations(for: expressionID, language: nil, region: nil)
    }
}
