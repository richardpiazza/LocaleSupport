public enum LocaleSupportError: Error {
    /// An unidentified `Locale.LanguageCode` was encountered.
    case languageCode(String)
    /// An unidentified `Locale.Region` was encountered.
    case region(String)
    /// An unidentified `Locale.Script` was encountered.
    case script(String)
}
