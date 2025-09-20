#if canImport(SwiftUI)
import SwiftUI

public extension Text {
    init(_ localizedStringConvertible: LocalizedStringConvertible) {
        self.init(localizedStringConvertible.localizedValue)
    }
}
#endif
