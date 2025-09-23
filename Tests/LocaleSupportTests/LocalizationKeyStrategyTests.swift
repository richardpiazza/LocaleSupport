@testable import LocaleSupport
import XCTest

final class LocalizationKeyStrategyTests: XCTestCase {

    let strategy: LocalizationKeyStrategy = .default

    func testKeyGeneration() {
        var key = strategy.key(from: "buttonTitleContinue", prefix: nil)
        XCTAssertEqual(key, "BUTTON_TITLE_CONTINUE")
        key = strategy.key(from: "buttonTitleContinue", prefix: "standard")
        XCTAssertEqual(key, "STANDARD_BUTTON_TITLE_CONTINUE")
        key = strategy.key(from: "button4Title", prefix: nil)
        XCTAssertEqual(key, "BUTTON_4_TITLE")
        key = strategy.key(from: "next", prefix: nil)
        XCTAssertEqual(key, "NEXT")
    }
}
