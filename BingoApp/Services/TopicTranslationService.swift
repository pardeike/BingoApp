import Foundation
import OpenAI

@Observable
@MainActor
final class TopicTranslationService: ObservableObject {
    enum TranslationError: LocalizedError {
        case missingAPIKey
        case unsupported

        var errorDescription: String? {
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
    private(set) var isConverting: Bool = false
    private(set) var lastError: Error?
    
    init(keyStore: OpenAIKeyStore) {
        self.keyStore = keyStore
        rebuildClient()
    }
    
    func rebuildClient() {
        if let token = keyStore.currentKey(), !token.isEmpty {
            client = OpenAI(apiToken: token)
        } else {
            client = nil
        }
    }
    
    func convertTopics(_ topics: [BingoTopic]) async -> [BingoTopic] {
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
        let query = CompletionsQuery(
            model: "gpt-3.5-turbo-instruct",
            prompt: prompt,
            maxTokens: 16,
            temperature: 0.2
        )
        let response = try await client.completions(query: query)
        guard let choice = response.choices.first else {
            throw TranslationError.unsupported
        }
        let short = choice.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return short.isEmpty ? text : short
    }
}
