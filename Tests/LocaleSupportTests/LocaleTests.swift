import Foundation
@testable import LocaleSupport
import Testing

struct LocaleTests {

    @Test func testAllCases() {
        #expect(Locale.LanguageCode.allCases.count == 107)
        #expect(Locale.Script.allCases.count == 37)
        #expect(Locale.Region.allCases.count == 255)
    }

    @Test func testLocalizedNames() {
        let englishUnitedStates = Locale(languageCode: .english, languageRegion: .unitedStates)
        #expect(Locale.LanguageCode.french.localizedName(for: englishUnitedStates) == "French")
        #expect(Locale.Script.hanSimplified.localizedName(for: englishUnitedStates) == "Simplified Han")
        #expect(Locale.Region.brazil.localizedName(for: englishUnitedStates) == "Brazil")
    }
}
