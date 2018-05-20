import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SerializationTests.allTests),
        testCase(StoreTests.allTests),
        testCase(FieldTests.allTests),
    ]
}
#endif
