import XCTest
@testable import LocaleSupport
@testable import TestResources

final class ExpressibleByLocalizedStringTests: XCTestCase {
    
    static var allTests = [
        ("testKey", testKey),
        ("testLocalizedValue", testLocalizedValue),
    ]
    
    private static var indicators: (prefix: Character, suffix: Character)? = nil
    private static var bundle: Bundle = .main
    
    private enum Strings: String, ExpressibleByLocalizedString {
        case alertTitle = "Delete Document"
        case alertMessage = "Are you sure you want to delete the document?"
        case confirm = "Yes"
        case cancel = "Cancel"
        
        var prefix: String? {
            switch self {
            case .confirm:
                return "standard"
            default:
                return nil
            }
        }
        
        var bundle: Bundle {
            return ExpressibleByLocalizedStringTests.bundle
        }
        
        var defaultIndicators: (prefix: Character, suffix: Character)? {
            return ExpressibleByLocalizedStringTests.indicators
        }
    }
    
    func testKey() {
        XCTAssertEqual(Strings.alertTitle.key, "ALERT_TITLE")
        XCTAssertEqual(Strings.alertMessage.key, "ALERT_MESSAGE")
        XCTAssertEqual(Strings.confirm.key, "STANDARD_CONFIRM")
        XCTAssertEqual(Strings.cancel.key, "CANCEL")
    }
    
    func testLocalizedValue() {
        XCTAssertEqual(Strings.alertTitle.localizedValue, "Delete Document")
        XCTAssertEqual(Strings.alertMessage.localizedValue, "Are you sure you want to delete the document?")
        XCTAssertEqual(Strings.confirm.localizedValue, "Yes")
        XCTAssertEqual(Strings.cancel.localizedValue, "Cancel")
        
        Self.indicators = ("[", "]")
        
        XCTAssertEqual(Strings.alertTitle.localizedValue, "[Delete Document]")
        XCTAssertEqual(Strings.alertMessage.localizedValue, "[Are you sure you want to delete the document?]")
        XCTAssertEqual(Strings.confirm.localizedValue, "[Yes]")
        XCTAssertEqual(Strings.cancel.localizedValue, "[Cancel]")
        
        Self.bundle = LocalizedStrings.bundle
        
        XCTAssertEqual(Strings.alertTitle.localizedValue, "Eliminar Documento")
        XCTAssertEqual(Strings.alertMessage.localizedValue, "¿Estás seguro de que deseas eliminar el documento?")
        XCTAssertEqual(Strings.confirm.localizedValue, "Si")
        XCTAssertEqual(Strings.cancel.localizedValue, "Cancelar")
    }
}
