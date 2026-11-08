/// Extension of `LocalizationReference` which adds behaviors and default values
/// making enum-driven loclization easier.
public protocol AnnotatedLocalizationReference: LocalizationReference {
    /// Strategy used to automatically generate keys
    var keyStrategy: LocalizationKeyStrategy { get }

    /// A optional prefix appended to the beginning of the key.
    ///
    /// It is a common practice to group string localizations to help identify purpose and clarify meaning. The default
    /// implementation will append any given value to the beginning of the generated localization 'key'.
    ///
    /// By default this will be processed using the `keyStrategy`.
    var prefix: String? { get }

    /// Characters that will be prepended/appended to the `value` if lookup fails.
    ///
    /// The default uses "[" & "]"; specify `nil` to disable this behavior.
    var defaultIndicator: DefaultValueIndicator? { get }
}

public extension AnnotatedLocalizationReference {
    var keyStrategy: LocalizationKeyStrategy {
        .default
    }

    var prefix: String? {
        nil
    }

    var defaultIndicator: DefaultValueIndicator? {
        .default
    }
}

public extension AnnotatedLocalizationReference where Self: RawRepresentable, Self.RawValue == String {
    var key: String {
        keyStrategy.key(from: String(describing: self), prefix: prefix)
    }

    /// `rawValue` of a `String` RawRepresentable case (with indicators if present).
    ///
    /// When an enumeration is declared to be using a `RawValue` of type `String`, the assumption will be that the value
    /// specified is the default value for localization should the '.strings' lookup fail.
    var value: String {
        if let defaultIndicator {
            String(defaultIndicator.prefix) + rawValue + String(defaultIndicator.suffix)
        } else {
            rawValue
        }
    }
}
