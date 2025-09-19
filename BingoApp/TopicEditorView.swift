import SwiftUI

struct TopicEditorView: View {
    @ObservedObject var topicManager: TopicManager
    @State private var topicText: String = ""
    @Environment(\.dismiss) private var dismiss
    let onTopicsChanged: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Enter topics for your bingo card (one per line):")
                    .font(.headline)
                
                TextEditor(text: $topicText)
                    .border(Color.gray, width: 1)
                    .frame(minHeight: 200)
                
                Text("Current topics: \(topicManager.topics.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !topicManager.topics.isEmpty {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(topicManager.topics) { topic in
                                HStack {
                                    Text("• \(topic.text)")
                                        .font(.body)
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
                    }
                    .frame(maxHeight: 200)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
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
                        if !topicText.isEmpty {
                            topicManager.addTopics(from: topicText)
                            topicText = ""
                            onTopicsChanged()
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let topicManager = TopicManager()
    topicManager.addTopics(from: "Sample Topic 1\nSample Topic 2\nSample Topic 3")
    
    return TopicEditorView(topicManager: topicManager) {}
}