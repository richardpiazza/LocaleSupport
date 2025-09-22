public struct LocalizationKey: LocalizedStringConvertible {

    public typealias Strategy = LocalizationKeyStrategy

    public let key: String
    public let strategy: Strategy
    public let defaultValue: String
    public let comment: String?

    public init(
        key: String,
        strategy: Strategy = .default,
        defaultValue: String,
        comment: String? = nil
    ) {
        self.key = key
        self.strategy = strategy
        self.defaultValue = defaultValue
        self.comment = comment
    }
}
