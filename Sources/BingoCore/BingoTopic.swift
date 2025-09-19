import Foundation
import Observation

/// Represents a single topic that can appear on a bingo card
public struct BingoTopic: Identifiable, Codable, Hashable {
    public var id: UUID
    public var text: String
    public var shortText: String?
    
    public init(id: UUID = UUID(), text: String, shortText: String? = nil) {
        self.id = id
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let shortText {
            self.shortText = shortText.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            self.shortText = nil
        }
    }
    
    /// Returns the best available display text for the topic.
    public var displayText: String {
        shortText?.isEmpty == false ? shortText! : text
    }
}

/// Manages the collection of available bingo topics
@Observable
public class TopicManager {
    public private(set) var topics: [BingoTopic] = []
    
    public init(topics: [BingoTopic] = []) {
        self.topics = topics
    }
    
    /// Add topics from a string where each line is a separate topic
    public func addTopics(from text: String) {
        let newTopics = text
            .components(separatedBy: .newlines)
            .map { sanitizeTopicText($0) }
            .filter { !$0.isEmpty }
            .map { BingoTopic(text: $0) }
        
        topics.append(contentsOf: newTopics)
    }

    /// Replace an existing topic's short text value.
    public func updateShortText(for topicID: UUID, shortText: String?) {
        guard let index = topics.firstIndex(where: { $0.id == topicID }) else { return }
        var updatedTopic = topics[index]
        updatedTopic.shortText = shortText?.trimmingCharacters(in: .whitespacesAndNewlines)
        topics[index] = updatedTopic
    }

    /// Replace all topics at once (used after conversions).
    public func replaceTopics(with newTopics: [BingoTopic]) {
        topics = newTopics
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

private func sanitizeTopicText(_ rawText: String) -> String {
    let trimmed = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return "" }
    if trimmed.hasPrefix("- ") {
        return String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
    }
    return trimmed
}
