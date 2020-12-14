import Foundation

public struct Translation: Identifiable, Codable {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case expressionID = "expression_id"
        case language = "language_code"
        case region = "region_code"
        case value
    }
    
    public enum Update {
        case expressionID(_ id: Expression.ID)
        case language(_ language: LanguageCode)
        case region(_ region: RegionCode?)
        case value(_ value: String)
    }
    
    /// Unique/Primary Key
    public let id: Int
    /// Expression (Foreign Key)
    public let expressionID: Expression.ID
    /// Language of the translation
    public var language: LanguageCode
    /// Region code specifier
    public var region: RegionCode?
    /// The translated string
    public var value: String
    
    public init(expressionID: Expression.ID, language: LanguageCode = .default, region: RegionCode? = nil, value: String) {
        id = -1
        self.expressionID = expressionID
        self.language = language
        self.region = region
        self.value = value
    }
    
    internal init(id: ID, expressionID: Expression.ID, language: LanguageCode, region: RegionCode?, value: String) {
        self.id = id
        self.expressionID = expressionID
        self.language = language
        self.region = region
        self.value = value
    }
}

public extension Translation {
    var designator: String {
        switch region {
        case .some(let code):
            return language.rawValue + "-" + code.rawValue
        case .none:
            return language.rawValue
        }
    }
}
