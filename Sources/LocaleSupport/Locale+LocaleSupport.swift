import Foundation

public extension Locale {
    enum Error: Swift.Error {
        case unavailableIdentifier(String)
    }
    
    init(_ id: String) throws {
        guard Locale.availableIdentifiers.contains(id) else {
            throw Error.unavailableIdentifier(id)
        }
        
        self.init(identifier: id)
    }
    
    init(language: LanguageCode, script: ScriptCode? = nil, region: RegionCode? = nil) throws {
        var id: String = language.rawValue
        if let script = script {
            id += "-\(script.rawValue)"
        }
        if let region = region {
            id += "_\(region.rawValue)"
        }
        
        try self.init(id)
    }
    
    /// Returns a localized string for a locale which contains the identifier and components
    func localizedString(for locale: Locale) -> String {
        var components: [String] = [locale.id]
        if let code = locale.languageCode, let language = localizedString(forLanguageCode: code) {
            components.append(language)
        }
        if let code = locale.scriptCode, let script = localizedString(forScriptCode: code) {
            components.append(script)
        }
        if let code = locale.regionCode, let region = localizedString(forLanguageCode: code) {
            components.append(region)
        }
        return components.joined(separator: " ")
    }
}

public extension Locale {
    /// Two character ISO 639-1 identifier
    var alpha2Code: String? { (languageCode?.count == 2) ? languageCode : nil }
    
    /// Three character ISO 639-2 identifier
    var alpha3Code: String? { (languageCode?.count == 3) ? languageCode : nil }
}

public extension Locale {
    internal static let english: Locale = Locale(identifier: "en")
    
    /// The US English language name
    var englishName: String? {
        if let language = languageCode {
            return Self.english.localizedString(forLanguageCode: language)
        } else {
            return nil
        }
    }
    
    /// The US English region name
    var englishRegion: String? {
        if let region = regionCode {
            return Self.english.localizedString(forRegionCode: region)
        } else {
            return nil
        }
    }
    
    var englishScript: String? {
        if let script = scriptCode {
            return Self.english.localizedString(forScriptCode: script)
        } else {
            return nil
        }
    }
}

extension Locale: Identifiable {
    public var id: String { identifier }
}
