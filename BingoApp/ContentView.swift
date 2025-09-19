import SwiftUI

struct ContentView: View {
    @StateObject private var topicManager = TopicManager()
    @StateObject private var bingoCard = BingoCard()
    @StateObject private var keyStore: OpenAIKeyStore
    @StateObject private var translationService: TopicTranslationService
    @State private var showingTopicEditor = false
    @State private var showingBingoDialog = false
    @State private var isConfirmingNewGame = false
    
    init() {
        let keyStore = OpenAIKeyStore()
        _keyStore = StateObject(wrappedValue: keyStore)
        _translationService = StateObject(wrappedValue: TopicTranslationService(keyStore: keyStore))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                topControls
                BingoCardView(bingoCard: bingoCard)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                if !topicManager.topics.isEmpty && bingoCard.tiles.isEmpty {
                    generateNewCard()
                }
            }
            .onChange(of: bingoCard.hasWon) { hasWonOld, hasWonNew in
                if hasWonNew {
                    showingBingoDialog = true
                }
            }
            .alert("Bingo!", isPresented: $showingBingoDialog) {
                Button("OK", role: .cancel) {
                    showingBingoDialog = false
                }
                Button("New Game") {
                    showingBingoDialog = false
                    generateNewCard()
                }
            } message: {
                Text("You completed a bingo. Nicely done!")
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private var topControls: some View {
        HStack(spacing: 12) {
            Spacer()
            Button("New Game") {
                isConfirmingNewGame = true
            }
            .disabled(topicManager.topics.isEmpty)
            Button("Configure Topics") {
                showingTopicEditor = true
            }
            .buttonStyle(.bordered)
        }
        .padding(.top)
        .confirmationDialog(
            "Start a new game?",
            isPresented: $isConfirmingNewGame,
            titleVisibility: .visible
        ) {
            Button("Start New Game", role: .destructive) {
                generateNewCard()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func generateNewCard() {
        bingoCard.generateCard(from: topicManager.topics)
        showingBingoDialog = false
    }
}
