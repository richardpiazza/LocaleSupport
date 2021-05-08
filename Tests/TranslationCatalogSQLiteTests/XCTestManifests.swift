import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CatalogDeleteTests.allTests),
        testCase(CatalogInsertTests.allTests),
    ]
}
#endif

