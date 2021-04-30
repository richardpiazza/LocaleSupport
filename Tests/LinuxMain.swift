import XCTest

import LocaleSupportTests
import LocalizerTests
import TranslationCatalogTests

var tests = [XCTestCaseEntry]()
tests += LocaleSupportTests.allTests()
tests += LocalizerTests.allTests()
tests += TranslationCatalogTests.allTests()
XCTMain(tests)
