import XCTest
import LMDBTests

var tests = [XCTestCaseEntry]()
tests += LMDBTests.allTests()
XCTMain(tests)
