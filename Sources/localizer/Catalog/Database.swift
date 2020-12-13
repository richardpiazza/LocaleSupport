import Foundation

public protocol Database {
    func expressions(includeTranslations: Bool) -> [Expression]
    func expression(_ id: Expression.ID) -> Expression?
    func expression(named name: String) -> Expression?
    func expressions(having language: LanguageCode, region: RegionCode?) -> [Expression]
    
    func translations() -> [Translation]
    func translation(_ id: Translation.ID) -> Translation?
    func translations(for expressionID: Expression.ID, language: LanguageCode?, region: RegionCode?) -> [Translation]
    
    func insert(_ expression: Expression) throws
    func insert(_ translation: Translation) throws
}

public extension Database {
    func expressions() -> [Expression] {
        return expressions(includeTranslations: false)
    }
    
    func translations(for expressionID: Expression.ID) -> [Translation] {
        return translations(for: expressionID, language: nil, region: nil)
    }
}
