import Foundation

@available(*, deprecated, renamed: "LocalizedStringConvertible")
public typealias ExpressibleByLocalizedString = LocalizedStringConvertible

/// Protocol defining the properties needed to produce string localizations.
///
/// Localization is one of the key differentiators between *good* apps and *great* apps. Though many development teams
/// take on this challenge only after the application is 'complete'.
///
/// The aim of `LocalizedStringConvertible` is to quicken the process of localization, at the same time, taking much
/// of the *guess-work* out of the picture.
///
/// When implemented on an `String` based enum, localization becomes a quick process that can be integrated at the
/// beginning of any project. An example implementation looks like this:
///
/// ```
/// /// Localized Strings for the MyAwesomeController class.
/// enum Strings: String, LocalizedStringConvertible {
///     /// My Awesome Controller
///     case navigationTitle = "My Awesome Controller"
///     /// Next
///     case nextButton = "Next"
///     /// Previous
///     case previousButton = "Previous"
/// }
/// ```
///
/// Each enumeration case will automagically reference a specific value in the default 'Localizable.strings' file. The
/// 'rawValue' will be used as the default value in the scenario where a key is not found. A `///` comment will provide
/// a quick code-completion hint.
///
/// For detailed information on using `String` resources, see
/// [Apple's Documentation](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html#//apple_ref/doc/uid/20000005-97055)
public protocol LocalizedStringConvertible {
    /// The '.strings' unique identifier for the localization
    var key: String { get }

    /// Optional file name in the '.strings' file containing the 'key'
    ///
    /// By default, specifying 'nil' for the 'tableName' in NSLocalizedString() will use the 'Localizable.strings' file.
    /// If multiple '.strings' files are in use, the specific file can be indicated.
    var tableName: String? { get }

    /// The `Bundle` where the localization table can be found
    ///
    /// If creating a shared library or multiple modules, the bundle value can be specified by overriding this value.
    var bundle: Bundle { get }

    /// The default value
    ///
    /// If a lookup fails to find a 'key' in the specified 'table', a default value should be provided.
    var defaultValue: String { get }

    /// A comment to clarify the intended usage of the localization
    ///
    /// This should be provided to translation teams to assist in proper proper translation.
    var comment: String? { get }

    /// A optional prefix appended to the beginning of the key.
    ///
    /// It is a common practice to group string localizations to help identify purpose and clarify meaning. The default
    /// implementation will append any given value to the beginning of the generated localization 'key'.
    ///
    /// - note: If a string is specified, it should be in the same style as the enumeration case (i.e. camelCase) with
    ///         no spaces or punctuation.
    var prefix: String? { get }

    /// Optional characters that will be prepended/appended to the `value` if used.
    ///
    /// This is handy if you want to easily know when the default value is used in your UI if lookup fails.
    ///
    /// The default implementation will proxy the `LocaleSupportConfiguration.defaultIndicators`.
    var defaultIndicators: (prefix: Character, suffix: Character)? { get }
}

public extension LocalizedStringConvertible {
    /// The value returned from 'NSLocalizedString(...)' or `Bundle.localizedString()`.
    var localizedValue: String {
        #if canImport(ObjectiveC)
        return NSLocalizedString(key, tableName: tableName, bundle: bundle, value: defaultValue, comment: comment ?? "")
        #else
        return bundle.localizedString(forKey: key, value: defaultValue, table: tableName)
        #endif
    }
}

// MARK: - Key Generation

public extension LocalizedStringConvertible {
    /// Generates a '.strings' key applying casing & prefixing as needed.
    ///
    /// Each localization needs a unique 'key' to be defined in the '.strings' files. If a `prefix` is specific, it will
    /// be appended to the beginning of the key name. This generates a '_' separated, uppercased representation of a
    /// camelCased string.
    ///
    /// ## Example
    /// The `String` 'navigationControllerTitle' would be converted to 'NAVIGATION_CONTROLLER_TITLE'.
    ///
    /// - parameter using: The camel-cased value for which to generate a key.
    func generateKey(using: String) -> String {
        let caseKey = using.replacingOccurrences(of: "([A-Z])", with: "_$1", options: .regularExpression).uppercased()

        if let prefix {
            let prefixKey = prefix.replacingOccurrences(of: "([A-Z])", with: "_$1", options: .regularExpression).uppercased()
            return "\(prefixKey)_\(caseKey)"
        } else {
            return caseKey
        }
    }

    /// By default, a key will automatically be generated from the enumeration case itself.
    var autogeneratedKey: String {
        generateKey(using: String(describing: self))
    }
}

// MARK: - Default Parameters

public extension LocalizedStringConvertible {
    var key: String { autogeneratedKey }
    var bundle: Bundle { .main }
    var tableName: String? { nil }
    var comment: String? { nil }
    var prefix: String? { nil }
    var defaultIndicators: (prefix: Character, suffix: Character)? { LocaleSupportConfiguration.defaultIndicators }
}

// MARK: - RawRepresentable Values

public extension LocalizedStringConvertible where Self: RawRepresentable, Self.RawValue == String {
    /// `rawValue` of a `String` RawRepresentable case (with indicators if present).
    ///
    /// When an enumeration is declared to be using a `RawValue` of type `String`, the assumption will be that the value
    /// specified is the default value for localization should the '.strings' lookup fail.
    var defaultValue: String {
        if let indicators = defaultIndicators {
            String(indicators.prefix) + rawValue + String(indicators.suffix)
        } else {
            rawValue
        }
    }
}
