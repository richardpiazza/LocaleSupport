/// Global configuration fot the **LocaleSupport** package.
public struct LocaleSupportConfiguration {
    private init() {
    }
    
    /// Characters that will be prepended/appended to any default `ExpressibleByLocalizedString` implementation.
    public static var defaultIndicators: (prefix: Character, suffix: Character)?
}
