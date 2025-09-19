import Foundation

/// Represents a single tile on the bingo card
public struct BingoTile: Identifiable, Codable {
    public var id = UUID()
    public let topic: BingoTopic
    public var isChecked: Bool = false
    
    public init(topic: BingoTopic) {
        self.topic = topic
    }
}

/// Represents a 5x5 bingo card
@Observable
public class BingoCard: ObservableObject {
    public private(set) var tiles: [[BingoTile]] = []
    public private(set) var hasWon: Bool = false
    
    public init() {}
    
    /// Generate a new 5x5 bingo card from the provided topics
    public func generateCard(from topics: [BingoTopic]) {
        guard topics.count >= 25 else {
            // If we don't have enough topics, fill with available ones and repeat as needed
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
    
    /// Toggle the checked state of a tile
    public func toggleTile(at row: Int, col: Int) {
        guard row >= 0, row < 5, col >= 0, col < 5 else { return }
        tiles[row][col].isChecked.toggle()
        checkForWin()
    }
    
    /// Check if the player has achieved a bingo (4 in a row)
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
        // Main diagonal (top-left to bottom-right)
        let mainDiagonal = (0..<5).map { tiles[$0][$0].isChecked }
        if hasConsecutiveChecked(tiles: mainDiagonal) {
            return true
        }
        
        // Anti diagonal (top-right to bottom-left)
        let antiDiagonal = (0..<5).map { tiles[$0][4-$0].isChecked }
        if hasConsecutiveChecked(tiles: antiDiagonal) {
            return true
        }
        
        return false
    }
    
    /// Check if there are 4 consecutive checked tiles in the array
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
    
    /// Reset all tiles to unchecked state
    public func resetCard() {
        for row in 0..<tiles.count {
            for col in 0..<tiles[row].count {
                tiles[row][col].isChecked = false
            }
        }
        hasWon = false
    }
}