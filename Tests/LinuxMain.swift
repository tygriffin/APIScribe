import XCTest

import SerializationTests

var tests = [XCTestCaseEntry]()
tests += SerializationTests.allTests()
XCTMain(tests)