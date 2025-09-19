import XCTest
@testable import BingoCore

@MainActor
final class TopicTranslationTests: XCTestCase {
    
    func testKeyStoreInitialization() {
        let keyStore = OpenAIKeyStore()
        
        // Initially should not have a saved key
        #if canImport(Security)
        XCTAssertFalse(keyStore.hasSavedKey)
        XCTAssertNil(keyStore.currentKey())
        #else
        // On non-iOS platforms, these methods exist but don't use keychain
        XCTAssertFalse(keyStore.hasSavedKey)
        XCTAssertNil(keyStore.currentKey())
        #endif
    }
    
    func testTranslationServiceInitialization() {
        let keyStore = OpenAIKeyStore()
        let service = TopicTranslationService(keyStore: keyStore)
        
        XCTAssertFalse(service.isConverting)
        XCTAssertNil(service.lastError)
    }
    
    func testTranslationServiceWithoutAPIKey() async {
        let keyStore = OpenAIKeyStore()
        let service = TopicTranslationService(keyStore: keyStore)
        
        let topics = [
            BingoTopic(text: "Read a book"),
            BingoTopic(text: "Go for a walk")
        ]
        
        let result = await service.convertTopics(topics)
        
        // Should return original topics unchanged when no API key
        XCTAssertEqual(result.count, topics.count)
        XCTAssertEqual(result[0].text, "Read a book")
        XCTAssertEqual(result[1].text, "Go for a walk")
        XCTAssertNil(result[0].shortText)
        XCTAssertNil(result[1].shortText)
        
        // Should have an error about missing API key
        XCTAssertNotNil(service.lastError)
        if let error = service.lastError as? TopicTranslationService.TranslationError {
            XCTAssertEqual(error, .missingAPIKey)
        }
    }
    
    func testBingoTopicDisplayText() {
        // Test topic without short text
        let topic1 = BingoTopic(text: "Read a really long book about history")
        XCTAssertEqual(topic1.displayText, "Read a really long book about history")
        
        // Test topic with short text
        var topic2 = BingoTopic(text: "Read a really long book about history")
        topic2.shortText = "Read Book"
        XCTAssertEqual(topic2.displayText, "Read Book")
        
        // Test topic with empty short text (should fall back to original)
        var topic3 = BingoTopic(text: "Go for a walk")
        topic3.shortText = ""
        XCTAssertEqual(topic3.displayText, "Go for a walk")
    }
    
    func testTopicManagerReplaceTopics() {
        let manager = TopicManager()
        manager.addTopics(from: "Topic 1\nTopic 2\nTopic 3")
        
        XCTAssertEqual(manager.topics.count, 3)
        
        // Test replacing with shortened topics
        var newTopics = manager.topics
        newTopics[0].shortText = "T1"
        newTopics[1].shortText = "T2"
        newTopics[2].shortText = "T3"
        
        manager.replaceTopics(with: newTopics)
        
        XCTAssertEqual(manager.topics.count, 3)
        XCTAssertEqual(manager.topics[0].shortText, "T1")
        XCTAssertEqual(manager.topics[1].shortText, "T2")
        XCTAssertEqual(manager.topics[2].shortText, "T3")
    }
}