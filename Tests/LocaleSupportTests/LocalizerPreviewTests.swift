import XCTest
@testable import localizer

final class LocalizerPreviewTests: LocalizerTestCase {
    
    static var allTests = [
        ("testPreviewAndroid", testPreviewAndroid),
        ("testPreviewApple", testPreviewApple),
    ]
    
    func testPreviewAndroid() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "Strings", withExtension: "xml"))
        
        process.arguments = ["preview", "android", resource.path]
        try process.run()
        process.waitUntilExit()
        
        XCTAssertEqual(output, """
        APP_NAME = Localizer
        NAVIGATION_TITLE = Welcome
        PERFORM_ACTION = Make It Go!
        
        """)
    }
    
    func testPreviewApple() throws {
        let resource = try XCTUnwrap(Bundle.module.url(forResource: "Localizable", withExtension: "strings"))
        
        process.arguments = ["preview", "apple", resource.path]
        try process.run()
        process.waitUntilExit()
        
        XCTAssertEqual(output, """
        APP_NAME = Localizer
        NAVIGATION_TITLE = Welcome
        PERFORM_ACTION = Make It Go!
        
        """)
    }
}
