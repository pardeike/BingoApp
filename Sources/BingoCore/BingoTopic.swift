import Foundation

/// Represents a single topic that can appear on a bingo card
public struct BingoTopic: Identifiable, Codable, Hashable {
    public let id = UUID()
    public let text: String
    
    public init(text: String) {
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Manages the collection of available bingo topics
public class TopicManager {
    public private(set) var topics: [BingoTopic] = []
    
    public init(topics: [BingoTopic] = []) {
        self.topics = topics
    }
    
    /// Add topics from a string where each line is a separate topic
    public func addTopics(from text: String) {
        let newTopics = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { BingoTopic(text: $0) }
        
        topics.append(contentsOf: newTopics)
    }
    
    /// Clear all topics
    public func clearTopics() {
        topics.removeAll()
    }
    
    /// Remove a specific topic
    public func removeTopic(_ topic: BingoTopic) {
        topics.removeAll { $0.id == topic.id }
    }
    
    /// Get a random selection of topics for the bingo card
    public func getRandomTopics(count: Int) -> [BingoTopic] {
        guard topics.count >= count else {
            return topics
        }
        return Array(topics.shuffled().prefix(count))
    }
}