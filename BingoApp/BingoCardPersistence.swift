import Foundation

/// Persists the current bingo card state so tile selections survive app restarts.
struct BingoCardState: Codable {
    var tiles: [[BingoTile]]
    var hasWon: Bool
}

public struct BingoCardPersistence {
    private let userDefaults: UserDefaults
    private let cardKey = "bingo.card.v1"
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func loadCard() -> BingoCardState? {
        guard let data = userDefaults.data(forKey: cardKey) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(BingoCardState.self, from: data)
        } catch {
            NSLog("BingoCardPersistence failed to decode card: \(error)")
            return nil
        }
    }
    
    func saveCard(_ state: BingoCardState?) {
        do {
            guard let state else {
                userDefaults.removeObject(forKey: cardKey)
                return
            }
            let data = try JSONEncoder().encode(state)
            userDefaults.set(data, forKey: cardKey)
        } catch {
            NSLog("BingoCardPersistence failed to save card: \(error)")
        }
    }
}
