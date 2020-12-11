import Foundation

public struct Value: Identifiable {
    /// Unique/Primary Key
    public var id: Int
    /// Foreign Key
    public var key: Key.ID
    public var language: LanguageCode
    public var region: RegionCode?
    /// The localized value for the language/region defined.
    public var localization: String
    
    public init(id: Int, key: Key.ID, language: LanguageCode = "", region: RegionCode?, localization: String = "") {
        self.id = id
        self.key = key
        self.language = language
        self.region = region
        self.localization = localization
    }
}

public extension Value {
    /// en-US, en-GB, en-AU
    var designator: String {
        guard let region = self.region, !region.isEmpty else {
            return language
        }
        
        return language + "-" + region
    }
}
