#if canImport(SwiftUI)
import SwiftUI

public extension Text {
    /// _Convenience_ initializer that automatically uses the `localizedValue` of the provided `LocalizedStringConvertible`.
    init(_ localizedStringConvertible: LocalizedStringConvertible) {
        self.init(localizedStringConvertible.localizedValue)
    }
}

public extension View {
    /// Configures the view’s title for purposes of navigation, using a string.
    ///
    /// Uses the `localizedValue` of the provided `LocalizedStringConvertible`.
    func navigationTitle(_ localizedStringConvertible: LocalizedStringConvertible) -> some View {
        navigationTitle(localizedStringConvertible.localizedValue)
    }
}
#endif
