import XCTest
@testable import Fahrten_Buch

final class Fahrten_BuchTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Fahrten_Buch().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
