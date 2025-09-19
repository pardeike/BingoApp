import Foundation
import Observation
import OpenAI

@Observable
@MainActor
public final class TopicTranslationService {
    public enum TranslationError: LocalizedError {
        case missingAPIKey
        case unsupported

        public var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "Please add your OpenAI API key before converting topics."
            case .unsupported:
                return "Unable to generate a short topic at this time."
            }
        }
    }
    
    private let keyStore: OpenAIKeyStore
    private var client: OpenAI?
    public private(set) var isConverting: Bool = false
    public private(set) var lastError: Error?
    
    public init(keyStore: OpenAIKeyStore) {
        self.keyStore = keyStore
        rebuildClient()
    }
    
    public func rebuildClient() {
        if let token = keyStore.currentKey(), !token.isEmpty {
            client = OpenAI(apiToken: token)
        } else {
            client = nil
        }
    }
    
    public func convertTopics(_ topics: [BingoTopic]) async -> [BingoTopic] {
        guard let client else {
            lastError = TranslationError.missingAPIKey
            return topics
        }
        isConverting = true
        defer { isConverting = false }
        lastError = nil
        
        var updatedTopics: [BingoTopic] = []
        for topic in topics {
            do {
                let short = try await convertTopic(topic.text, client: client)
                var newTopic = topic
                newTopic.shortText = short
                updatedTopics.append(newTopic)
            } catch {
                lastError = error
                updatedTopics.append(topic)
            }
        }
        
        return updatedTopics
    }
    
    private func convertTopic(_ text: String, client: OpenAI) async throws -> String {
        let prompt = """
        Rewrite the following bingo topic into a super short 2-3 word phrase that still conveys the idea. Avoid punctuation. Topic: \(text)
        """
        
        // Use the chat completions API instead of legacy completions
        let query = ChatQuery(
            messages: [ChatQuery.ChatCompletionMessageParam.user(.init(content: .string(prompt)))],
            model: .gpt3_5Turbo,
            temperature: 0.2
        )
        
        let response = try await client.chats(query: query)
        guard let choice = response.choices.first,
              let content = choice.message.content else {
            throw TranslationError.unsupported
        }
        
        let short = content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return short.isEmpty ? text : short
    }
}