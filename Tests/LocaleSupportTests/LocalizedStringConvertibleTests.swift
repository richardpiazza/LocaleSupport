#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
@testable import LocaleSupport
import Testing

struct LocalizedStringConvertibleTests {

    private struct TestLocalizedValues: LocalizedStringConvertible, RawRepresentable {
        let caseName: String
        let rawValue: String
        let prefix: String?
        let defaultValueIndicator: DefaultValueIndicator?
        let bundle: Bundle

        var key: String { strategy.key(from: caseName, prefix: prefix) }

        init?(rawValue: String) {
            return nil
        }

        init(
            caseName: String,
            defaultValue: String,
            prefix: String? = nil,
            defaultValueIndicator: DefaultValueIndicator? = nil,
            bundle: Bundle = .main,
        ) {
            self.caseName = caseName
            self.rawValue = defaultValue
            self.prefix = prefix
            self.defaultValueIndicator = defaultValueIndicator
            self.bundle = bundle
        }
    }

    private enum Strings: String, LocalizedStringConvertible {
        case alertTitle = "Delete Document"
        case alertMessage = "Are you sure you want to delete the document?"
        case confirm = "Yes"
        case cancel = "Cancel"

        var prefix: String? {
            switch self {
            case .confirm:
                "standard"
            default:
                nil
            }
        }

        var bundle: Bundle { .module }
    }

    @Test func testKey() {
        #expect(Strings.alertTitle.key == "ALERT_TITLE")
        #expect(Strings.alertMessage.key == "ALERT_MESSAGE")
        #expect(Strings.confirm.key == "STANDARD_CONFIRM")
        #expect(Strings.cancel.key == "CANCEL")

        let alertTitle = TestLocalizedValues(caseName: "alertTitle", defaultValue: "Delete Document")
        let alertMessage = TestLocalizedValues(caseName: "alertMessage", defaultValue: "Are you sure you want to delete the document?")
        let confirm = TestLocalizedValues(caseName: "confirm", defaultValue: "Yes", prefix: "standard")
        let cancel = TestLocalizedValues(caseName: "cancel", defaultValue: "Cancel")

        #expect(alertTitle.key == "ALERT_TITLE")
        #expect(alertMessage.key == "ALERT_MESSAGE")
        #expect(confirm.key == "STANDARD_CONFIRM")
        #expect(cancel.key == "CANCEL")
    }

    @Test func testLocalizedValue() {
        var alertTitle = TestLocalizedValues(caseName: "alertTitle", defaultValue: "Delete Document")
        var alertMessage = TestLocalizedValues(caseName: "alertMessage", defaultValue: "Are you sure you want to delete the document?")
        var confirm = TestLocalizedValues(caseName: "confirm", defaultValue: "Yes", prefix: "standard")
        var cancel = TestLocalizedValues(caseName: "cancel", defaultValue: "Cancel")

        #expect(alertTitle.localizedValue == "Delete Document")
        #expect(alertMessage.localizedValue == "Are you sure you want to delete the document?")
        #expect(confirm.localizedValue == "Yes")
        #expect(cancel.localizedValue == "Cancel")

        alertTitle = TestLocalizedValues(
            caseName: "alertTitle",
            defaultValue: "Delete Document",
            defaultValueIndicator: .openCloseBracket
        )
        alertMessage = TestLocalizedValues(
            caseName: "alertMessage",
            defaultValue: "Are you sure you want to delete the document?",
            defaultValueIndicator: .openCloseBracket
        )
        confirm = TestLocalizedValues(
            caseName: "confirm",
            defaultValue: "Yes",
            prefix: "standard",
            defaultValueIndicator: .openCloseBracket
        )
        cancel = TestLocalizedValues(
            caseName: "cancel",
            defaultValue: "Cancel",
            defaultValueIndicator: .openCloseBracket
        )

        #expect(alertTitle.localizedValue == "[Delete Document]")
        #expect(alertMessage.localizedValue == "[Are you sure you want to delete the document?]")
        #expect(confirm.localizedValue == "[Yes]")
        #expect(cancel.localizedValue == "[Cancel]")

        alertTitle = TestLocalizedValues(
            caseName: "alertTitle",
            defaultValue: "Delete Document",
            bundle: .module,
        )
        alertMessage = TestLocalizedValues(
            caseName: "alertMessage",
            defaultValue: "Are you sure you want to delete the document?",
            bundle: .module,
        )
        confirm = TestLocalizedValues(
            caseName: "confirm",
            defaultValue: "Yes",
            prefix: "standard",
            bundle: .module,
        )
        cancel = TestLocalizedValues(
            caseName: "cancel",
            defaultValue: "Cancel",
            bundle: .module,
        )

        #expect(alertTitle.localizedValue == "Eliminar Documento")
        #expect(alertMessage.localizedValue == "¿Estás seguro de que deseas eliminar el documento?")
        #expect(confirm.localizedValue == "Si")
        #expect(cancel.localizedValue == "Cancelar")
    }

    @Test func testEnumLocalizedValues() {
        #expect(Strings.alertTitle.localizedValue == "Eliminar Documento")
        #expect(Strings.alertMessage.localizedValue == "¿Estás seguro de que deseas eliminar el documento?")
        #expect(Strings.confirm.localizedValue == "Si")
        #expect(Strings.cancel.localizedValue == "Cancelar")
    }
}
