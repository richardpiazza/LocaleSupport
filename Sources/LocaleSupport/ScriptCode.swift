/// Designator used when ambiguity needs to be resolved for a particular language and/or language & region pair.
public enum ScriptCode: String, CaseIterable, Codable, Hashable, Sendable {
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
}
