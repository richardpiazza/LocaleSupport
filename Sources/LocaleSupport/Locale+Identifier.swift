import Foundation

public extension Locale {

    typealias Identifier = String
    
    init(_ id: String) throws {
        guard Locale.availableIdentifiers.contains(id) else {
            throw LocaleSupportError.unavailableLocaleIdentifier(id)
        }
        
        self.init(identifier: id)
    }
    
    init(
        language: LocaleSupport.LanguageCode,
        script: ScriptCode? = nil,
        region: RegionCode? = nil
    ) throws {
        var id: String = language.rawValue
        if let script = script {
            id += "-\(script.rawValue)"
        }
        if let region = region {
            id += "_\(region.rawValue)"
        }
        
        try self.init(id)
    }
}
