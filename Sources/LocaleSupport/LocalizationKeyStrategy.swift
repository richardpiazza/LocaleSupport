public struct LocalizationKeyStrategy {
    public enum Casing {
        case uppercase
    }

    public enum Splitting {
        case numbers
        case uppercaseCharacters
    }

    public let casing: Casing
    public let splitting: Set<Splitting>
    public let separator: Character

    public init(
        casing: Casing = .uppercase,
        splitting: Set<Splitting> = [.numbers, .uppercaseCharacters],
        separator: Character = "_"
    ) {
        self.casing = casing
        self.splitting = splitting
        self.separator = separator
    }

    public static let `default`: LocalizationKeyStrategy = LocalizationKeyStrategy()

    /// Generates a '.strings' key applying casing, splitting & prefixing as needed.
    ///
    /// Each localization needs a unique 'key' to be defined in the '.strings' files. If a `prefix` is specified, it will
    /// be appended to the beginning of the key name.
    ///
    /// - parameters:
    ///   - from: The unique value used for the key.
    ///   - prefix: Additional value appended to the beginning of the key.
    public func key(from: String, prefix: String?) -> String {
        var mutatedFrom = from
        var mutatedPrefix = prefix ?? ""

        for split in splitting {
            let captureGroup = switch split {
            case .numbers: "([0-9])"
            case .uppercaseCharacters: "([A-Z])"
            }

            mutatedFrom = mutatedFrom.replacingOccurrences(
                of: captureGroup,
                with: "\(separator)$1",
                options: .regularExpression
            )

            mutatedPrefix = mutatedPrefix.replacingOccurrences(
                of: captureGroup,
                with: "\(separator)$1",
                options: .regularExpression
            )
        }

        let prefixComponents = mutatedPrefix
            .split(separator: separator)
            .map { String($0) }
        let fromComponents = mutatedFrom
            .split(separator: separator)
            .map { String($0) }

        let components = switch casing {
        case .uppercase:
            (prefixComponents + fromComponents).map { $0.uppercased() }
        }

        return components.joined(separator: String(separator))
    }
}
