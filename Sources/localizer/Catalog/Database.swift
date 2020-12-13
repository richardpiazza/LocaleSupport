import Foundation

public protocol Database {
    func expressions(includeTranslations: Bool) -> [Expression]
    func expression(_ id: Expression.ID) -> Expression?
    func expression(named name: String) -> Expression?
    func expressions(having language: LanguageCode, region: RegionCode?) -> [Expression]
    
    func translations() -> [Translation]
    func translation(_ id: Translation.ID) -> Translation?
    func translations(for expressionID: Expression.ID, language: LanguageCode?, region: RegionCode?) -> [Translation]
    
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
    func expressions() -> [Expression] {
        return expressions(includeTranslations: false)
    }
    
    func translations(for expressionID: Expression.ID) -> [Translation] {
        return translations(for: expressionID, language: nil, region: nil)
    }
}
