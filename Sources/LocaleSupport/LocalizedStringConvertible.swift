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
public protocol LocalizedStringConvertible: AnnotatedLocalizationReference, BundleRetrievable {}

public extension LocalizedStringConvertible {
    @available(*, deprecated, renamed: "value")
    var defaultValue: String {
        value
    }

    @available(*, deprecated, renamed: "keyStrategy")
    var strategy: LocalizationKeyStrategy {
        keyStrategy
    }

    @available(*, deprecated, renamed: "defaultIndicator")
    var defaultValueIndicator: DefaultValueIndicator? {
        defaultIndicator
    }
}
