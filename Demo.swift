#!/usr/bin/env swift

import Foundation

// Copy the core functionality here for demo
struct BingoTopic: Identifiable, Codable, Hashable {
    let id = UUID()
    let text: String
    
    init(text: String) {
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct BingoTile: Identifiable, Codable {
    let id = UUID()
    let topic: BingoTopic
    var isChecked: Bool = false
    
    init(topic: BingoTopic) {
        self.topic = topic
    }
}

class TopicManager {
    private(set) var topics: [BingoTopic] = []
    
    init(topics: [BingoTopic] = []) {
        self.topics = topics
    }
    
    func addTopics(from text: String) {
        let newTopics = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { BingoTopic(text: $0) }
        
        topics.append(contentsOf: newTopics)
    }
    
    func clearTopics() {
        topics.removeAll()
    }
    
    func getRandomTopics(count: Int) -> [BingoTopic] {
        guard topics.count >= count else {
            return topics
        }
        return Array(topics.shuffled().prefix(count))
    }
}

class BingoCard {
    private(set) var tiles: [[BingoTile]] = []
    private(set) var hasWon: Bool = false
    
    init() {}
    
    func generateCard(from topics: [BingoTopic]) {
        guard topics.count >= 25 else {
            let repeatedTopics = Array(repeating: topics, count: (25 / max(topics.count, 1)) + 1)
                .flatMap { $0 }
                .prefix(25)
            generateCard(from: Array(repeatedTopics))
            return
        }
        
        let selectedTopics = Array(topics.shuffled().prefix(25))
        tiles = []
        
        for row in 0..<5 {
            var tileRow: [BingoTile] = []
            for col in 0..<5 {
                let index = row * 5 + col
                tileRow.append(BingoTile(topic: selectedTopics[index]))
            }
            tiles.append(tileRow)
        }
        
        hasWon = false
    }
    
    func toggleTile(at row: Int, col: Int) {
        guard row >= 0, row < 5, col >= 0, col < 5 else { return }
        tiles[row][col].isChecked.toggle()
        checkForWin()
    }
    
    private func checkForWin() {
        hasWon = checkRows() || checkColumns() || checkDiagonals()
    }
    
    private func checkRows() -> Bool {
        for row in tiles {
            if hasConsecutiveChecked(tiles: row.map { $0.isChecked }) {
                return true
            }
        }
        return false
    }
    
    private func checkColumns() -> Bool {
        for col in 0..<5 {
            let columnTiles = tiles.map { $0[col].isChecked }
            if hasConsecutiveChecked(tiles: columnTiles) {
                return true
            }
        }
        return false
    }
    
    private func checkDiagonals() -> Bool {
        let mainDiagonal = (0..<5).map { tiles[$0][$0].isChecked }
        if hasConsecutiveChecked(tiles: mainDiagonal) {
            return true
        }
        
        let antiDiagonal = (0..<5).map { tiles[$0][4-$0].isChecked }
        if hasConsecutiveChecked(tiles: antiDiagonal) {
            return true
        }
        
        return false
    }
    
    private func hasConsecutiveChecked(tiles: [Bool]) -> Bool {
        var count = 0
        for isChecked in tiles {
            if isChecked {
                count += 1
                if count >= 4 {
                    return true
                }
            } else {
                count = 0
            }
        }
        return false
    }
    
    func displayCard() {
        print("\n🎯 BINGO CARD")
        print("═══════════════════════════════════════════════════════════════════════════════")
        
        for (rowIndex, row) in tiles.enumerated() {
            var line = ""
            for (colIndex, tile) in row.enumerated() {
                let status = tile.isChecked ? "✅" : "⬜"
                let text = String(tile.topic.text.prefix(12)).padding(toLength: 12, withPad: " ", startingAt: 0)
                line += "[\(rowIndex),\(colIndex)] \(status) \(text) │ "
            }
            print(line)
        }
        
        print("═══════════════════════════════════════════════════════════════════════════════")
        
        if hasWon {
            print("🎉 BINGO! You won! 🎉")
        } else {
            print("Check off 4 in a row (horizontal, vertical, or diagonal) to win!")
        }
        print()
    }
}

// Demo
print("🎲 BINGO APP DEMO")
print("═════════════════════════════════════════════════════════════════════")

let topicManager = TopicManager()

let sampleTopics = """
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

print("\n📝 Adding sample topics...")
topicManager.addTopics(from: sampleTopics)
print("Added \(topicManager.topics.count) topics!")

print("\n🎯 Generating random 5x5 bingo card...")
let bingoCard = BingoCard()
bingoCard.generateCard(from: topicManager.topics)

bingoCard.displayCard()

print("💡 DEMO: Let's simulate checking off the first row to demonstrate winning:")
print("Checking tiles [0,0], [0,1], [0,2], [0,3]...")

for col in 0..<4 {
    bingoCard.toggleTile(at: 0, col: col)
    print("\nAfter checking [\(0),\(col)]:")
    bingoCard.displayCard()
    if bingoCard.hasWon {
        break
    }
}

print("✨ Demo complete!")
print("\n📱 To use the iOS SwiftUI app:")
print("1. Open BingoApp.xcodeproj in Xcode")
print("2. Build and run on iOS Simulator or device")
print("3. Tap 'Topics' to add your own topics")
print("4. Tap 'New Game' to generate a new card")
print("5. Tap tiles to check them off")
print("6. Get 4 in a row to win!")