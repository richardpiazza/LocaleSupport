@testable import LocaleSupport
import Testing

struct LocalizationKeyStrategyTests {

    @Test func `key generation`() {
        let strategy: LocalizationKeyStrategy = .default

        var key = strategy.key(from: "buttonTitleContinue", prefix: nil)
        #expect(key == "BUTTON_TITLE_CONTINUE")
        key = strategy.key(from: "buttonTitleContinue", prefix: "standard")
        #expect(key == "STANDARD_BUTTON_TITLE_CONTINUE")
        key = strategy.key(from: "button4Title", prefix: nil)
        #expect(key == "BUTTON_4_TITLE")
        key = strategy.key(from: "next", prefix: nil)
        #expect(key == "NEXT")
    }

    @Test func `multiple numers`() {
        var strategy: LocalizationKeyStrategy = .default

        var key = strategy.key(from: "button4Title", prefix: nil)
        #expect(key == "BUTTON_4_TITLE")
        key = strategy.key(from: "button44Title", prefix: nil)
        #expect(key == "BUTTON_44_TITLE")
        key = strategy.key(from: "button444Title", prefix: nil)
        #expect(key == "BUTTON_444_TITLE")

        strategy = LocalizationKeyStrategy(splitting: [.uppercaseCharacters])
        key = strategy.key(from: "button4Title", prefix: nil)
        #expect(key == "BUTTON4_TITLE")
        key = strategy.key(from: "button44Title", prefix: nil)
        #expect(key == "BUTTON44_TITLE")
        key = strategy.key(from: "button444Title", prefix: nil)
        #expect(key == "BUTTON444_TITLE")

        strategy = LocalizationKeyStrategy(splitting: [.anyDigit, .uppercaseCharacters])
        key = strategy.key(from: "button4Title", prefix: nil)
        #expect(key == "BUTTON_4_TITLE")
        key = strategy.key(from: "button44Title", prefix: nil)
        #expect(key == "BUTTON_4_4_TITLE")
        key = strategy.key(from: "button444Title", prefix: nil)
        #expect(key == "BUTTON_4_4_4_TITLE")
    }
}
