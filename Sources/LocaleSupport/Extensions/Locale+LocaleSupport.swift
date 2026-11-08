import Foundation

extension Locale: @retroactive Identifiable {
    public var id: String {
        identifier
    }
}
