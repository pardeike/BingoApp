import Foundation
import Observation
import OpenAI

public enum TopicLanguage: String, CaseIterable, Identifiable {
    case english
    case german
    case swedish

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .english: "English"
        case .german: "Deutsch"
        case .swedish: "Svenska"
        }
    }

    private func instructions(expectedCount: Int) -> String {
        switch self {
        case .english:
            """
            You generate concise English bingo tile labels. Respond with a JSON object that matches the schema {"topics": ["..."]} and contains exactly \(expectedCount) unique entries. Each entry must be a 2-3 word English phrase that preserves the meaning of the matching long topic, keeps the same order, and avoids punctuation.
            """
        case .german:
            """
            Du erzeugst kurze deutsche Bingo-Begriffe. Gib ein JSON-Objekt im Schema {"topics": ["..."]} mit genau \(expectedCount) eindeutigen Einträgen zurück. Jeder Eintrag muss eine deutsche Phrase aus 2-3 Wörtern sein, die die Bedeutung des ursprünglichen Themas beibehält, die Reihenfolge respektiert und keine Satzzeichen enthält.
            """
        case .swedish:
            """
            Du tar fram korta svenska bingofraser. Svara med ett JSON-objekt enligt schemat {"topics": ["..."]} som innehåller exakt \(expectedCount) unika fraser. Varje fras ska bestå av 2-3 svenska ord, behålla innebörden av sitt ursprungliga ämne, följa samma ordning och sakna skiljetecken.
            """
        }
    }

    fileprivate func prompt(for topics: [BingoTopic]) -> String {
        let expectedCount = topics.count
        let topicsBlock = topics
            .map { "- \($0.text)" }
            .joined(separator: "\n")
        return """
        \(instructions(expectedCount: expectedCount))

        Long topics (keep order and meaning):
        \(topicsBlock)
        """
    }
}

@Observable
@MainActor
public final class TopicTranslationService: ObservableObject {
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

    init(keyStore: OpenAIKeyStore) {
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

    public func convertTopics(_ topics: [BingoTopic], language: TopicLanguage) async -> [BingoTopic] {
        guard let client else {
            lastError = TranslationError.missingAPIKey
            return topics
        }
        guard !topics.isEmpty else {
            return topics
        }
        isConverting = true
        defer { isConverting = false }
        lastError = nil

        do {
            return try await convertTopicsInBatch(topics, language: language, client: client)
        } catch {
            lastError = error
            return topics
        }
    }

    private func convertTopicsInBatch(
        _ topics: [BingoTopic],
        language: TopicLanguage,
        client: OpenAI
    ) async throws -> [BingoTopic] {
        let expectedCount = topics.count
        let prompt = language.prompt(for: topics)

        let shortTopicsSchema = JSONSchema.schema(
            .type(.object),
            .properties([
                "topics": JSONSchema.schema(
                    .type(.array),
                    .items(
                        JSONSchema.schema(
                            .type(.string),
                            .minLength(1),
                            .maxLength(40)
                        )
                    ),
                    .minItems(expectedCount),
                    .maxItems(expectedCount),
                    // .uniqueItems(true) not permitted
                )
            ]),
            .required(["topics"]),
            .additionalProperties(.boolean(false))
        )

        let responseFormat = ChatQuery.ResponseFormat.jsonSchema(
            .init(
                name: "shorttopics",
                description: "Short bingo topics in \(language.displayName)",
                schema: .jsonSchema(shortTopicsSchema),
                strict: true
            )
        )

        let systemMessage = ChatQuery.ChatCompletionMessageParam.system(
            .init(content: .textContent("You reply with JSON that matches the provided schema."))
        )
        let userMessage = ChatQuery.ChatCompletionMessageParam.user(.init(content: .string(prompt)))

        let query = ChatQuery(
            messages: [systemMessage, userMessage],
            model: .gpt5,
            responseFormat: responseFormat,
            // temperature (gpt5 does not support temperature)
        )

        let response = try await client.chats(query: query)
        guard let choice = response.choices.first,
              let content = choice.message.content else {
            throw TranslationError.unsupported
        }

        let shortened = try decodeStructuredTopics(from: content, expectedCount: expectedCount)

        return zip(topics, shortened).map { topic, short in
            var topic = topic
            topic.shortText = short
            return topic
        }
    }

    private func decodeStructuredTopics(from content: String, expectedCount: Int) throws -> [String] {
        guard let data = content.data(using: .utf8) else {
            throw TranslationError.unsupported
        }

        let payload = try JSONDecoder().decode(ShortTopicsPayload.self, from: data)
        return try normalizeShortTopics(payload.topics, expectedCount: expectedCount)
    }

    private func normalizeShortTopics(_ topics: [String], expectedCount: Int) throws -> [String] {
        guard topics.count == expectedCount else {
            throw TranslationError.unsupported
        }

        var seen: Set<String> = []
        var results: [String] = []
        results.reserveCapacity(expectedCount)

        for original in topics {
            let trimmed = original.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw TranslationError.unsupported
            }

            let normalized = capitalizingFirstCharacter(trimmed)

            if seen.insert(normalized).inserted {
                results.append(normalized)
                continue
            }

            var suffix = 2
            var candidate = "\(normalized) \(suffix)"
            while !seen.insert(candidate).inserted {
                suffix += 1
                if suffix > 99 {
                    throw TranslationError.unsupported
                }
                candidate = "\(normalized) \(suffix)"
            }
            results.append(candidate)
        }

        return results
    }
}

private struct ShortTopicsPayload: Decodable {
    let topics: [String]
}

private func capitalizingFirstCharacter(_ text: String) -> String {
    guard let firstIndex = text.firstIndex(where: { $0.isLetter || $0.isNumber }) else {
        return text
    }

    var result = text
    let uppercasedFirst = String(result[firstIndex]).uppercased()
    result.replaceSubrange(firstIndex...firstIndex, with: uppercasedFirst)
    return result
}
