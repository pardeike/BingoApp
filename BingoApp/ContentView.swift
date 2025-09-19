import SwiftUI
import BingoCore

struct ContentView: View {
    @StateObject private var topicManager = TopicManager()
    @StateObject private var bingoCard = BingoCard()
    @StateObject private var keyStore: OpenAIKeyStore
    @StateObject private var translationService: TopicTranslationService
    @State private var showingTopicEditor = false
    
    init() {
        let keyStore = OpenAIKeyStore()
        _keyStore = StateObject(wrappedValue: keyStore)
        _translationService = StateObject(wrappedValue: TopicTranslationService(keyStore: keyStore))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if bingoCard.hasWon {
                    Text("🎉 BINGO! 🎉")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .animation(.bouncy, value: bingoCard.hasWon)
                }
                
                BingoCardView(bingoCard: bingoCard)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                VStack(spacing: 12) {
                    Button("New Game") {
                        generateNewCard()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(topicManager.topics.isEmpty)
                    
                    Button("Reset Card") {
                        bingoCard.resetCard()
                    }
                    .buttonStyle(.bordered)
                    .disabled(topicManager.topics.isEmpty)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Bingo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Topics") {
                        showingTopicEditor = true
                    }
                }
            }
            .sheet(isPresented: $showingTopicEditor) {
                TopicEditorView(
                    topicManager: topicManager,
                    keyStore: keyStore,
                    translationService: translationService
                ) {
                    if !topicManager.topics.isEmpty && bingoCard.tiles.isEmpty {
                        generateNewCard()
                    }
                }
            }
            .onAppear {
                // Add some default topics if none exist
                if topicManager.topics.isEmpty {
                    addDefaultTopics()
                    generateNewCard()
                }
            }
        }
    }
    
    private func generateNewCard() {
        bingoCard.generateCard(from: topicManager.topics)
    }
    
    private func addDefaultTopics() {
        let defaultTopics = """
        Read a book
        Go for a walk
        Cook a meal
        Watch a movie
        Call a friend
        Exercise
        Listen to music
        Write in a journal
        Learn something new
        Take a photo
        Clean the house
        Play a game
        Visit a museum
        Try a new restaurant
        Go to a concert
        Plant something
        Meditate
        Paint or draw
        Volunteer
        Go hiking
        Visit the beach
        Try a new hobby
        Organize a space
        Have a picnic
        Dance
        Read the news
        Practice gratitude
        Take a nap
        Go stargazing
        Bake something
        """
        topicManager.addTopics(from: defaultTopics)
    }
}
