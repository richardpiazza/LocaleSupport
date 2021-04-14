import LocaleSupport
import Foundation

public protocol Database {
    func expressions(includeTranslations: Bool) throws -> [Expression]
    func expression(_ id: Expression.ID) throws -> Expression
    func expression(named name: String) throws -> Expression
    /// Retrieves expressions that match a specific language/region.
    ///
    /// - parameter language: The `LanguageCode` to match
    /// - parameter script: The optional `ScriptCode` to match
    /// - parameter region: The optional `RegionCode` to match
    /// - parameter fallback: When a _script/region_is specified, and a matching translation is not found, the region-less
    ///                       (if available) expression will be provided. (See 'export' command).
    func expressions(having language: LanguageCode, script: ScriptCode?, region: RegionCode?, fallback: Bool) throws -> [Expression]
    
    func translations() throws -> [Translation]
    func translation(_ id: Translation.ID) throws -> Translation
    func translations(for expressionID: Expression.ID, language: LanguageCode?, script: ScriptCode?, region: RegionCode?) throws -> [Translation]
    
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
    
    func expressions(having language: LanguageCode, script: ScriptCode?, region: RegionCode?) throws -> [Expression] {
        return try expressions(having: language, script: script, region: region, fallback: true)
    }
    
    
    func translations(for expressionID: Expression.ID) throws -> [Translation] {
        return try translations(for: expressionID, language: nil, script: nil, region: nil)
    }
}
