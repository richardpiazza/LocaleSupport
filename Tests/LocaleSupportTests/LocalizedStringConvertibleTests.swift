import Foundation
@testable import LocaleSupport
import Testing

struct LocalizedStringConvertibleTests {

    private struct StringsStruct: RawRepresentable, LocalizedStringConvertible {
        let rawValue: String
        let caseName: String
        let prefix: String?
        let defaultIndicator: DefaultValueIndicator?
        let bundle: Bundle

        var key: String {
            keyStrategy.key(from: caseName, prefix: prefix)
        }

        init?(rawValue: String) {
            nil
        }

        init(
            rawValue: String,
            caseName: String,
            prefix: String? = nil,
            defaultIndicator: DefaultValueIndicator? = nil,
            bundle: Bundle = .main,
        ) {
            self.rawValue = rawValue
            self.caseName = caseName
            self.prefix = prefix
            self.defaultIndicator = defaultIndicator
            self.bundle = bundle
        }
    }

    private enum StringsEnum: String, LocalizedStringConvertible {
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

        var bundle: Bundle {
            .module
        }
    }

    @Test func `Strings Enum Key Generation`() {
        #expect(StringsEnum.alertTitle.key == "ALERT_TITLE")
        #expect(StringsEnum.alertMessage.key == "ALERT_MESSAGE")
        #expect(StringsEnum.confirm.key == "STANDARD_CONFIRM")
        #expect(StringsEnum.cancel.key == "CANCEL")
    }

    @Test func `Strings Enum Localized Values`() {
        #expect(StringsEnum.alertTitle.localizedValue == "Eliminar Documento")
        #expect(StringsEnum.alertMessage.localizedValue == "¿Estás seguro de que deseas eliminar el documento?")
        #expect(StringsEnum.confirm.localizedValue == "Si")
        #expect(StringsEnum.cancel.localizedValue == "Cancelar")
    }

    @Test func `Strings Struct Key Generation`() {
        let alertTitle = StringsStruct(
            rawValue: "Delete Document",
            caseName: "alertTitle",
        )
        let alertMessage = StringsStruct(
            rawValue: "Are you sure you want to delete the document?",
            caseName: "alertMessage",
        )
        let confirm = StringsStruct(
            rawValue: "Yes",
            caseName: "confirm",
            prefix: "standard",
        )
        let cancel = StringsStruct(
            rawValue: "Cancel",
            caseName: "cancel",
        )

        #expect(alertTitle.key == "ALERT_TITLE")
        #expect(alertMessage.key == "ALERT_MESSAGE")
        #expect(confirm.key == "STANDARD_CONFIRM")
        #expect(cancel.key == "CANCEL")
    }

    @Test func `Strings Struct Localized Values`() {
        var alertTitle = StringsStruct(
            rawValue: "Delete Document",
            caseName: "alertTitle",
            defaultIndicator: nil,
        )
        var alertMessage = StringsStruct(
            rawValue: "Are you sure you want to delete the document?",
            caseName: "alertMessage",
            defaultIndicator: nil,
        )
        var confirm = StringsStruct(
            rawValue: "Yes",
            caseName: "confirm",
            prefix: "standard",
            defaultIndicator: nil,
        )
        var cancel = StringsStruct(
            rawValue: "Cancel",
            caseName: "cancel",
            defaultIndicator: nil,
        )

        #expect(alertTitle.localizedValue == "Delete Document")
        #expect(alertMessage.localizedValue == "Are you sure you want to delete the document?")
        #expect(confirm.localizedValue == "Yes")
        #expect(cancel.localizedValue == "Cancel")

        alertTitle = StringsStruct(
            rawValue: "Delete Document",
            caseName: "alertTitle",
            defaultIndicator: .openCloseBracket,
        )
        alertMessage = StringsStruct(
            rawValue: "Are you sure you want to delete the document?",
            caseName: "alertMessage",
            defaultIndicator: .openCloseBracket,
        )
        confirm = StringsStruct(
            rawValue: "Yes",
            caseName: "confirm",
            prefix: "standard",
            defaultIndicator: .openCloseBracket,
        )
        cancel = StringsStruct(
            rawValue: "Cancel",
            caseName: "cancel",
            defaultIndicator: .openCloseBracket,
        )

        #expect(alertTitle.localizedValue == "[Delete Document]")
        #expect(alertMessage.localizedValue == "[Are you sure you want to delete the document?]")
        #expect(confirm.localizedValue == "[Yes]")
        #expect(cancel.localizedValue == "[Cancel]")

        alertTitle = StringsStruct(
            rawValue: "Delete Document",
            caseName: "alertTitle",
            bundle: .module,
        )
        alertMessage = StringsStruct(
            rawValue: "Are you sure you want to delete the document?",
            caseName: "alertMessage",
            bundle: .module,
        )
        confirm = StringsStruct(
            rawValue: "Yes",
            caseName: "confirm",
            prefix: "standard",
            bundle: .module,
        )
        cancel = StringsStruct(
            rawValue: "Cancel",
            caseName: "cancel",
            bundle: .module,
        )

        #expect(alertTitle.localizedValue == "Eliminar Documento")
        #expect(alertMessage.localizedValue == "¿Estás seguro de que deseas eliminar el documento?")
        #expect(confirm.localizedValue == "Si")
        #expect(cancel.localizedValue == "Cancelar")
    }
}
