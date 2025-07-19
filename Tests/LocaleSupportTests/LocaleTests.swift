@testable import LocaleSupport
import XCTest

final class LocaleTests: XCTestCase {
    
    func testAllCases() {
        XCTAssertEqual(Locale.LanguageCode.allCases.count, 107)
        XCTAssertEqual(Locale.Script.allCases.count, 37)
        XCTAssertEqual(Locale.Region.allCases.count, 255)
    }
    
    func testLocalizedNames() {
        let englishUnitedStates = Locale(languageCode: .english, languageRegion: .unitedStates)
        XCTAssertEqual(Locale.LanguageCode.french.localizedName(for: englishUnitedStates), "French")
        XCTAssertEqual(Locale.Script.hanSimplified.localizedName(for: englishUnitedStates), "Simplified Han")
        XCTAssertEqual(Locale.Region.brazil.localizedName(for: englishUnitedStates), "Brazil")
    }
}
