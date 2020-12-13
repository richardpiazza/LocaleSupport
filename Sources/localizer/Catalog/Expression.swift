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
    
    public let id: Int
    public var name: String
    public var defaultLanguage: LanguageCode
    public var comment: String?
    public var feature: String?
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
