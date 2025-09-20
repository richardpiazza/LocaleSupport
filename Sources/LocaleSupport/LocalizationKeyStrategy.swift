public struct LocalizationKeyStrategy {
    public enum Casing {
        case uppercase
    }

    public let casing: Casing
    public let separator: Character

    public init(
        casing: Casing = .uppercase,
        separator: Character = "_"
    ) {
        self.casing = casing
        self.separator = separator
    }

    public static let `default`: LocalizationKeyStrategy = LocalizationKeyStrategy()
}
