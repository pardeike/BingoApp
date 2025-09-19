import XCTest
@testable import BingoCoreTests

fileprivate extension BingoCoreTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__BingoCoreTests = [
        ("testBingoCardGeneration", testBingoCardGeneration),
        ("testBingoWinCondition", testBingoWinCondition),
        ("testTopicCreation", testTopicCreation),
        ("testTopicManagerAddTopics", testTopicManagerAddTopics)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __BingoCoreTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BingoCoreTests.__allTests__BingoCoreTests)
    ]
}