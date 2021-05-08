import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CatalogDeleteProjectTests.allTests),
        testCase(CatalogGenerateTests.allTests),
        testCase(LocalizerPreviewTests.allTests),
        testCase(LocalizerTests.allTests),
    ]
}
#endif
