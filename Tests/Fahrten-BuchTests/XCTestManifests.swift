import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Fahrten_BuchTests.allTests),
    ]
}
#endif