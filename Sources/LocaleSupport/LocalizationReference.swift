/// Core components that define a localized string.
public protocol LocalizationReference {
    /// The unique key associated with the localization
    var key: String { get }
    /// The value associated to the `key`
    var value: String { get }
    /// Clarifying information about this localized string.
    var comment: String? { get }
}

public extension LocalizationReference {
    var comment: String? {
        nil
    }
}
