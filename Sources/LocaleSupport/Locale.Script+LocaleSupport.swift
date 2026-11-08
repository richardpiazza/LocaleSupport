import Foundation

public extension Locale.Script {
    /// Initializes a `Locale.Script` checking that it matched a _known_ instance.
    init(matching knownIdentifier: String) throws {
        let script = Locale.Script(knownIdentifier)
        guard Self.allCases.contains(script) else {
            throw LocaleSupportError.script(knownIdentifier)
        }

        self = script
    }

    /// A localized representation for the identifier using the current `Locale.`
    var localizedName: String? {
        localizedName()
    }

    /// A localized representation for the identifier using the provided `Locale.`
    func localizedName(for locale: Locale = .current) -> String? {
        locale.localizedString(forScriptCode: identifier)
    }
}

extension Locale.Script: @retroactive Identifiable {
    public var id: String {
        identifier
    }
}

extension Locale.Script: @retroactive CaseIterable {
    public static let allCases: [Locale.Script] = [
        .adlam,
        .arabic,
        .arabicNastaliq,
        .armenian,
        .bangla,
        .cherokee,
        .cyrillic,
        .devanagari,
        .ethiopic,
        .georgian,
        .greek,
        .gujarati,
        .gurmukhi,
        .hanifiRohingya,
        .hanSimplified,
        .hanTraditional,
        .hebrew,
        .hiragana,
        .japanese,
        .kannada,
        .katakana,
        .khmer,
        .korean,
        .lao,
        .latin,
        .malayalam,
        .meiteiMayek,
        .myanmar,
        .odia,
        .olChiki,
        .sinhala,
        .syriac,
        .tamil,
        .telugu,
        .thaana,
        .thai,
        .tibetan,
    ]
}
