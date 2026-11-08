import Foundation

/// Isolates Foundation.Bundle access for sring localization.
public protocol BundleRetrievable {
    /// The `Bundle` where the localization table can be found
    ///
    /// If creating a shared library or multiple modules, the bundle value can be specified by overriding this value.
    var bundle: Bundle { get }

    /// Optional file name in the '.strings' file containing the 'key'
    ///
    /// By default, specifying 'nil' for the 'tableName' will use the 'Localizable.strings' file.
    /// If multiple '.strings' files are in use, the specific file can be indicated.
    var table: String? { get }
}

public extension BundleRetrievable {
    var bundle: Bundle {
        .main
    }

    var table: String? {
        nil
    }
}

public extension LocalizationReference where Self: BundleRetrievable {
    var localizedValue: String {
        bundle.localizedString(forKey: key, value: value, table: table)
    }
}
