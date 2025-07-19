import XCTest
@testable import LocaleSupport

final class LocalizedStringConvertibleTests: XCTestCase {
    
    private static var bundle: Bundle = .main
    
    private enum Strings: String, LocalizedStringConvertible {
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
            return LocalizedStringConvertibleTests.bundle
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
        
        LocaleSupportConfiguration.defaultIndicators = ("[", "]")
        
        XCTAssertEqual(Strings.alertTitle.localizedValue, "[Delete Document]")
        XCTAssertEqual(Strings.alertMessage.localizedValue, "[Are you sure you want to delete the document?]")
        XCTAssertEqual(Strings.confirm.localizedValue, "[Yes]")
        XCTAssertEqual(Strings.cancel.localizedValue, "[Cancel]")
        
        LocaleSupportConfiguration.defaultIndicators = nil
        
        Self.bundle = LocalizedStrings.bundle
        
        XCTAssertEqual(Strings.alertTitle.localizedValue, "Eliminar Documento")
        XCTAssertEqual(Strings.alertMessage.localizedValue, "¿Estás seguro de que deseas eliminar el documento?")
        XCTAssertEqual(Strings.confirm.localizedValue, "Si")
        XCTAssertEqual(Strings.cancel.localizedValue, "Cancelar")
    }
}
