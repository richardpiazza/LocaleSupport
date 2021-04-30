import XCTest
@testable import localizer
import class Foundation.Bundle

class LocalizerTestCase: XCTestCase {
    
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
    
    lazy var pipe: Pipe = {
        return Pipe()
    }()
    
    lazy var process: Process = {
        let process = Process()
        process.executableURL = productsDirectory.appendingPathComponent("localizer")
        process.standardOutput = pipe
        return process
    }()
    
    var output: String? {
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
}
