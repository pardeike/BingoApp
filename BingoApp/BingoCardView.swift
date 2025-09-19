import SwiftUI

struct BingoCardView: View {
    @ObservedObject var bingoCard: BingoCard
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<bingoCard.tiles.count, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<bingoCard.tiles[row].count, id: \.self) { col in
                        BingoTileView(
                            tile: bingoCard.tiles[row][col],
                            onTap: {
                                bingoCard.toggleTile(at: row, col: col)
                            }
                        )
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

struct BingoTileView: View {
    let tile: BingoTile
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Rectangle()
                    .fill(tile.isChecked ? Color.green.opacity(0.3) : Color.white)
                    .border(Color.gray, width: 1)
                
                Text(tile.topic.text)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(tile.isChecked ? .green : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(4)
                
                if tile.isChecked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                        .background(Color.white.clipShape(Circle()))
                }
            }
        }
        .frame(width: 65, height: 65)
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let sampleTopics = [
        BingoTopic(text: "Read a book"),
        BingoTopic(text: "Go for a walk"),
        BingoTopic(text: "Cook a meal"),
        BingoTopic(text: "Watch a movie"),
        BingoTopic(text: "Call a friend")
    ]
    
    let bingoCard = BingoCard()
    bingoCard.generateCard(from: sampleTopics)
    
    return BingoCardView(bingoCard: bingoCard)
        .padding()
}