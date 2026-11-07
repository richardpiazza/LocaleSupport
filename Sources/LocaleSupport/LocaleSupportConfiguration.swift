/// Global configuration for the **LocaleSupport** package.
@available(*, deprecated, message: "Use `DefaultValueIndicator`")
public struct LocaleSupportConfiguration {
    private init() {}

    /// Characters that will be prepended/appended to any default `LocalizedStringConvertible` implementation.
    @available(*, deprecated)
    public static var defaultIndicators: (prefix: Character, suffix: Character)?
}
