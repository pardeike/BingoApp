import SwiftUI
import BingoCore

struct BingoCardView: View {
    @ObservedObject var bingoCard: BingoCard
    private let spacing: CGFloat = 8
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
    
    var body: some View {
        GeometryReader { geometry in
            let availableHeight = max(geometry.size.height - (spacing * 4), 340)
            let tileHeight = availableHeight / 5
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(0..<bingoCard.tiles.count, id: \.self) { row in
                    ForEach(0..<bingoCard.tiles[row].count, id: \.self) { col in
                        BingoTileView(
                            tile: bingoCard.tiles[row][col],
                            onTap: {
                                bingoCard.toggleTile(at: row, col: col)
                            }
                        )
                        .frame(height: tileHeight)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, minHeight: 420)
        .padding(12)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

struct BingoTileView: View {
    let tile: BingoTile
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(tile.isChecked ? Color.green.opacity(0.3) : Color.white)
                    .border(Color.gray, width: 1)
                
                Text(tile.topic.displayText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(tile.isChecked ? .green : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 10)
                
                if tile.isChecked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                        .background(Color.white.clipShape(Circle()))
                        .padding(6)
                }
            }
        }
        .frame(maxWidth: .infinity)
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
        .frame(height: 440)
        .padding()
}
