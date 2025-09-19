import XCTest
@testable import BingoCore

final class BingoCoreTests: XCTestCase {
    
    func testTopicCreation() {
        let topic = BingoTopic(text: "  Test Topic  ")
        XCTAssertEqual(topic.text, "Test Topic")
        XCTAssertNotNil(topic.id)
    }
    
    func testTopicManagerAddTopics() {
        let manager = TopicManager()
        let topicsText = "Topic 1\nTopic 2\n\nTopic 3\n"
        
        manager.addTopics(from: topicsText)
        
        XCTAssertEqual(manager.topics.count, 3)
        XCTAssertEqual(manager.topics[0].text, "Topic 1")
        XCTAssertEqual(manager.topics[1].text, "Topic 2")
        XCTAssertEqual(manager.topics[2].text, "Topic 3")
    }
    
    func testBingoCardGeneration() {
        let topics = (1...25).map { BingoTopic(text: "Topic \($0)") }
        let card = BingoCard()
        
        card.generateCard(from: topics)
        
        XCTAssertEqual(card.tiles.count, 5)
        for row in card.tiles {
            XCTAssertEqual(row.count, 5)
        }
        XCTAssertFalse(card.hasWon)
    }
    
    func testBingoWinCondition() {
        let topics = (1...25).map { BingoTopic(text: "Topic \($0)") }
        let card = BingoCard()
        
        card.generateCard(from: topics)
        
        // Check first row to win
        for col in 0..<4 {
            card.toggleTile(at: 0, col: col)
        }
        
        XCTAssertTrue(card.hasWon)
    }
}