import Foundation

/// Persists the list of bingo topics between app launches.
public struct TopicPersistence {
    private let userDefaults: UserDefaults
    private let topicsKey = "bingo.topics.v1"
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func loadTopics() -> [BingoTopic] {
        guard let data = userDefaults.data(forKey: topicsKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([BingoTopic].self, from: data)
        } catch {
            NSLog("TopicPersistence failed to decode topics: \(error)")
            return []
        }
    }
    
    func saveTopics(_ topics: [BingoTopic]) {
        do {
            if topics.isEmpty {
                userDefaults.removeObject(forKey: topicsKey)
            } else {
                let data = try JSONEncoder().encode(topics)
                userDefaults.set(data, forKey: topicsKey)
            }
        } catch {
            NSLog("TopicPersistence failed to save topics: \(error)")
        }
    }
}
