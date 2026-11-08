/// Characters that will be applied to a Localized String value if a lookup fails,
/// and the 'default value' is used instead.
public struct DefaultValueIndicator: Hashable, Sendable {
    public let prefix: Character
    public let suffix: Character

    public init(
        prefix: Character = "[",
        suffix: Character = "]",
    ) {
        self.prefix = prefix
        self.suffix = suffix
    }

    public static let `default`: DefaultValueIndicator = DefaultValueIndicator()
    public static var openCloseBracket: DefaultValueIndicator {
        .default
    }
}
