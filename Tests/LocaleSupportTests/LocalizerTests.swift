import XCTest
@testable import localizer
import class Foundation.Bundle

final class LocalizerTests: XCTestCase {
    
    static var allTests = [
        ("textExecute", testExecute),
    ]
    
    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }
    
    func testExecute() throws {
        let pipe = Pipe()
        
        let process = Process()
        process.executableURL = productsDirectory.appendingPathComponent("localizer")
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        XCTAssertEqual(output, """
        OVERVIEW: Android 'strings.xml' & Apple 'Localizable.strings' utility.

        Default Language Code: en
        Default Region Code: US

        USAGE: localizer <subcommand>

        OPTIONS:
          --version               Show the version.
          -h, --help              Show help information.
        
        SUBCOMMANDS:
          preview                 Displays the localizations found in a translation
                                  file.
          catalog                 Interact with the translation catalog.
          import                  Imports a translation file into the catalog.
          export                  Export a translation file using the catalog.
          configure               Displays or alters the command configuration details.

          See 'localizer help <subcommand>' for detailed help.
        
        """)
    }
}
