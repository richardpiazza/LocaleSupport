/// Designator used when ambiguity needs to be resolved for a particular language and/or language & region pair.
@available(*, deprecated, message: "Use `Foundation.Locale.Script`.")
public enum ScriptCode: String, Hashable, Identifiable, Sendable, CaseIterable, Codable {
    case Arab
    case Beng
    case Cyrl
    case Deva
    case Hans
    case Hant
    case Latn
    case Mtei
    case Olck
    case Tfng

    public var id: String { rawValue }
}
