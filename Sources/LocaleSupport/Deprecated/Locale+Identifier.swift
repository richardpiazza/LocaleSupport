import Foundation

public extension Locale {

    @available(*, deprecated)
    typealias Identifier = String

    @available(*, deprecated)
    init(_ id: String) throws {
        guard Locale.availableIdentifiers.contains(id) else {
            throw LocaleSupportError.unavailableLocaleIdentifier(id)
        }

        self.init(identifier: id)
    }

    @available(*, deprecated)
    init(
        language: LocaleSupport.LanguageCode,
        script: ScriptCode? = nil,
        region: RegionCode? = nil
    ) throws {
        var id: String = language.rawValue
        if let script {
            id += "-\(script.rawValue)"
        }
        if let region {
            id += "_\(region.rawValue)"
        }

        try self.init(id)
    }
}
