import SwiftUI

struct BingoCardView: View {
    @ObservedObject var bingoCard: BingoCard
    @State private var infoTile: BingoTile?
    private let spacing: CGFloat = 8
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
    
    var body: some View {
        GeometryReader { geometry in
            let totalHorizontalSpacing = spacing * 4
            let totalVerticalSpacing = spacing * 4
            let availableWidth = max(geometry.size.width - totalHorizontalSpacing, 0)
            let availableHeight = max(geometry.size.height - totalVerticalSpacing, 0)
            let tileWidth = availableWidth / 5
            let tileHeight = availableHeight / 5
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(Array(bingoCard.tiles.enumerated()), id: \.offset) { rowIndex, row in
                    ForEach(Array(row.enumerated()), id: \.element.id) { colIndex, tile in
                        BingoTileView(
                            tile: tile,
                            onTap: {
                                bingoCard.toggleTile(at: rowIndex, col: colIndex)
                            },
                            onLongPress: {
                                infoTile = tile
                            }
                        )
                        .frame(width: tileWidth, height: tileHeight)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(item: $infoTile) { tile in
            let short = tile.topic.shortText?.isEmpty == false ? tile.topic.shortText! : tile.topic.text
            let messageText = tile.topic.shortText?.isEmpty == false ? tile.topic.text : nil
            return Alert(
                title: Text(short),
                message: messageText.map(Text.init),
                dismissButton: .default(Text("Close"))
            )
        }
    }
}

struct BingoTileView: View {
    let tile: BingoTile
    let onTap: () -> Void
    let onLongPress: () -> Void
    @State private var suppressNextTap = false

    private var tileShape: some Shape {
        RoundedRectangle(cornerRadius: 12)
    }

    var body: some View {
        Button {
            if suppressNextTap {
                suppressNextTap = false
                return
            }
            onTap()
        } label: {
            Text(tile.topic.displayText)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineLimit(4)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                .background(
                    tileShape.fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    tileShape
                        .stroke(tile.isChecked ? Color.green : Color.gray.opacity(0.5), lineWidth: tile.isChecked ? 3 : 1)
                )
                .animation(.easeInOut(duration: 0.2), value: tile.isChecked)
        }
        .buttonStyle(.plain)
        .contentShape(tileShape)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                suppressNextTap = true
                onLongPress()
            }
        )
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
