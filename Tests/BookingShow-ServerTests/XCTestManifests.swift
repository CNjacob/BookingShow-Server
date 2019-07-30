import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BookingShow_ServerTests.allTests),
    ]
}
#endif
