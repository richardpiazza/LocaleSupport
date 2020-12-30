import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ExpressibleByLocalizedStringTests.allTests),
        testCase(LocalizerPreviewTests.allTests),
        testCase(LocalizerTests.allTests),
    ]
}
#endif
