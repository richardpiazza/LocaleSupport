import XCTest

final class CatalogGenerateTests: _LocalizerTestCase {
    
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
    }
    
}
