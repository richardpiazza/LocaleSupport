import Foundation

public struct Translation: Identifiable, Codable {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case expressionID = "expression_id"
        case language = "language_code"
        case region = "region_code"
        case value
    }
    
    public let id: Int
    public let expressionID: Expression.ID
    public var language: LanguageCode
    public var region: RegionCode?
    public var value: String
    
    public init(language: LanguageCode = .default, region: RegionCode? = nil, value: String) {
        id = -1
        expressionID = -1
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
