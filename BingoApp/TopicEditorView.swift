import SwiftUI

struct TopicEditorView: View {
    @ObservedObject var topicManager: TopicManager
    @ObservedObject var keyStore: OpenAIKeyStore
    @ObservedObject var translationService: TopicTranslationService
    @State private var topicText: String = ""
    @State private var apiKeyInput: String = ""
    @State private var keySaveError: String?
    @State private var conversionMessage: String?
    @Environment(\.dismiss) private var dismiss
    let onTopicsChanged: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Enter topics for your bingo card (one per line):")
                        .font(.headline)
                    
                    TextEditor(text: $topicText)
                        .border(Color.gray, width: 1)
                        .frame(minHeight: 200)
                    
                    Button(action: addTopicsIfNeeded) {
                        Text("Add Topics")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(topicText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Divider()
                    
                    topicSummary
                    
                    Divider()
                    
                    conversionControls
                    
                    Divider()
                    
                    apiKeySection
                }
                .padding()
            }
            .navigationTitle("Manage Topics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        topicManager.clearTopics()
                        onTopicsChanged()
                    }
                    .foregroundColor(.red)
                    .disabled(topicManager.topics.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        addTopicsIfNeeded()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var topicSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current topics: \(topicManager.topics.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !topicManager.topics.isEmpty {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(topicManager.topics) { topic in
                        HStack(alignment: .top, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(topic.text)
                                    .font(.body)
                                if let shortText = topic.shortText, !shortText.isEmpty {
                                    Text(shortText)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Button("Delete") {
                                topicManager.removeTopic(topic)
                                onTopicsChanged()
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    @ViewBuilder
    private var conversionControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Conversion")
                .font(.headline)
            Text("Generate short versions that fit on bingo tiles.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: convertTopics) {
                if translationService.isConverting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Convert Topics to Short Titles")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(topicManager.topics.isEmpty || translationService.isConverting)
            
            if let conversionMessage {
                Text(conversionMessage)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            if let error = translationService.lastError {
                Text(errorMessage(from: error))
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var apiKeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OpenAI API Key")
                .font(.headline)
            Text("Paste your key to enable AI conversion. The key is stored securely and never displayed.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            SecureField("Paste API Key", text: $apiKeyInput)
                .textContentType(.password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button("Save API Key") {
                saveAPIKey()
            }
            .buttonStyle(.borderedProminent)
            .disabled(apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            if let keySaveError {
                Text(keySaveError)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
            
            if keyStore.hasSavedKey {
                Text("API key saved.")
                    .font(.footnote)
                    .foregroundColor(.green)
            }
        }
    }
    
    private func addTopicsIfNeeded() {
        let trimmed = topicText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        topicManager.addTopics(from: trimmed)
        topicText = ""
        onTopicsChanged()
        conversionMessage = nil
    }
    
    private func convertTopics() {
        conversionMessage = nil
        Task {
            let updatedTopics = await translationService.convertTopics(topicManager.topics)
            topicManager.replaceTopics(with: updatedTopics)
            onTopicsChanged()
            if translationService.lastError == nil {
                conversionMessage = "Updated short titles for \(updatedTopics.count) topics."
            }
        }
    }
    
    private func saveAPIKey() {
        keySaveError = nil
        let key = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }
        do {
            try keyStore.save(key: key)
            translationService.rebuildClient()
            apiKeyInput = ""
        } catch {
            keySaveError = errorMessage(from: error)
        }
    }
    
    private func errorMessage(from error: Error) -> String {
        if let localized = error as? LocalizedError, let description = localized.errorDescription {
            return description
        }
        return error.localizedDescription
    }
}

#Preview {
    let topicManager = TopicManager()
    topicManager.addTopics(from: "Sample Topic 1\nSample Topic 2\nSample Topic 3")
    let keyStore = OpenAIKeyStore()
    let translationService = TopicTranslationService(keyStore: keyStore)
    
    return TopicEditorView(
        topicManager: topicManager,
        keyStore: keyStore,
        translationService: translationService
    ) {}
}
