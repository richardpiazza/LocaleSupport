import Foundation

public struct Expression: Identifiable, Codable {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case defaultLanguage = "default_language"
        case comment
        case feature
        case translations
    }
    
    public enum Query {
        case id(_ id: Expression.ID)
        case name(_ name: String)
    }
    
    public enum Update {
        case name(_ name: String)
        case defaultLanguage(_ language: LanguageCode)
        case comment(_ comment: String?)
        case feature(_ feature: String?)
    }
    
    /// Unique/Primary Key
    public let id: Int
    /// Key that identifies a collection of translations.
    public var name: String
    /// The default/development language code.
    public var defaultLanguage: LanguageCode
    /// Contextual information that guides translators.
    public var comment: String?
    /// Optional grouping identifier.
    public var feature: String?
    /// Associated translations.
    public var translations: [Translation]
    
    public init(
        name: String,
        defaultLanguage: LanguageCode = .default,
        comment: String? = nil,
        feature: String? = nil,
        translations: [Translation] = []
    ) {
        id = -1
        self.name = name
        self.defaultLanguage = defaultLanguage
        self.comment = comment
        self.feature = feature
        self.translations = translations
    }
    
    internal init(
        id: ID,
        name: String,
        defaultLanguage: LanguageCode,
        comment: String?,
        feature: String?,
        translations: [Translation]
    ) {
        self.id = id
        self.name = name
        self.defaultLanguage = defaultLanguage
        self.comment = comment
        self.feature = feature
        self.translations = translations
    }
}
