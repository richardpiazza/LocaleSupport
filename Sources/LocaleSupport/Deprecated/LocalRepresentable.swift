import Foundation

@available(*, deprecated, message: "Use `Foundation.Locale`")
public protocol LocaleRepresentable {
    var languageCode: LanguageCode { get }
    var scriptCode: ScriptCode? { get }
    var regionCode: RegionCode? { get }
}

@available(*, deprecated, message: "Use `Foundation.Locale.identifier`")
public extension LocaleRepresentable {
    var localeIdentifier: Locale.Identifier {
        var output = languageCode.rawValue
        if let scriptCode {
            output += "-\(scriptCode.rawValue)"
        }
        if let regionCode {
            output += "_\(regionCode.rawValue)"
        }
        return output
    }
}
