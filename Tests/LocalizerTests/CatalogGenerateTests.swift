import XCTest

final class CatalogGenerateTests: LocalizerTestCase {
    
    static var allTests = [
        ("testExecute", testExecute),
    ]
    
    func testExecute() throws {
        process.arguments = ["catalog", "generate", "markdown", "--path", path]
        try process.run()
        process.waitUntilExit()
        
        XCTAssertEqual(output, """
        # Strings
        
        """)
        
        try recycle()
    }
    
}
