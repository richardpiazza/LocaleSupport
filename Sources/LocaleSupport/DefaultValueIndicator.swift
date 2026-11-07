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

    public static let openCloseBracket: DefaultValueIndicator = DefaultValueIndicator()
}
