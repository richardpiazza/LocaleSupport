import Foundation

public protocol Database {
    func keys(includeValues: Bool) -> [Key]
    func key(_ id: Key.ID) -> Key?
    func key(named name: String) -> Key?
    func keys(havingLanguage language: LanguageCode, region: RegionCode?) -> [Key]
    
    func values() -> [Value]
    func value(_ id: Key.ID) -> Value?
    func values(for key: Key.ID, language: LanguageCode?, region: RegionCode?) -> [Value]
    
    func insert(_ key: Key) throws
    func insert(_ value: Value) throws
}

public extension Database {
    func keys() -> [Key] {
        return keys(includeValues: false)
    }
    
    func values(for key: Key.ID) -> [Value] {
        return values(for: key, language: nil, region: nil)
    }
}
