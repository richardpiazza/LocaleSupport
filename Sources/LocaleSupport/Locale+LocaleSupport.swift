import Foundation

#if hasFeature(RetroactiveAttribute)
extension Locale: @retroactive Identifiable {
    public var id: String { identifier }
}
#else
extension Locale: Identifiable {
    public var id: String { identifier }
}
#endif
