import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LocalizerPreviewTests.allTests),
        testCase(LocalizerTests.allTests),
    ]
}
#endif
