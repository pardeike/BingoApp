# BingoApp

A SwiftUI iOS app that generates random 5x5 bingo cards from custom topics. Users can submit their own list of topics (one per row) and play bingo by checking off completed items. Get 4 in a row to win! 🎉

## Features

- 📝 **Custom Topic Management**: Submit and manage your own list of topics (one per line)
- 🎯 **5x5 Bingo Card Generation**: Creates random bingo cards from your topic list
- ✅ **Interactive Tiles**: Tap tiles to check them off as you complete activities
- 🏆 **Win Detection**: Automatically detects when you get 4 in a row (horizontal, vertical, or diagonal)
- 🔄 **New Game Function**: Generate fresh random cards anytime
- 📱 **Modern iOS Interface**: Built with SwiftUI for iOS 16+

## Demo

Run the included demo to see the functionality in action:

```bash
swift Demo.swift
```

This will show you:
- Topic management (adding 30 sample topics)
- Random 5x5 bingo card generation
- Interactive tile checking
- Win detection when you get 4 in a row

## Project Structure

```
BingoApp/
├── Package.swift                    # Swift Package Manager configuration
├── Demo.swift                       # Console demo script
├── BingoApp.xcodeproj/             # Xcode project file
├── BingoApp/                       # iOS SwiftUI App
│   ├── BingoAppApp.swift           # App entry point
│   ├── ContentView.swift           # Main app interface
│   ├── BingoCardView.swift         # 5x5 bingo card display
│   ├── TopicEditorView.swift       # Topic management interface
│   ├── BingoTopic.swift            # Topic data model
│   ├── BingoCard.swift             # Bingo card logic
│   └── Assets.xcassets/            # App icons and assets
├── Sources/BingoCore/              # Core Swift Package
│   ├── BingoTopic.swift            # Topic management logic
│   └── BingoCard.swift             # Bingo card and win detection
└── Tests/BingoCoreTests/           # Unit tests
    └── BingoCoreTests.swift        # Core functionality tests
```

## Core Components

### TopicManager
Manages the collection of bingo topics:
- Add topics from multi-line text (one topic per line)
- Clear all topics
- Remove individual topics
- Get random selection for bingo cards

### BingoCard
Handles the 5x5 bingo card logic:
- Generate random cards from available topics
- Toggle tile checked state
- Detect wins (4 consecutive tiles in any direction)
- Reset cards for new games

### SwiftUI Views
- **ContentView**: Main app with navigation and game controls
- **BingoCardView**: Interactive 5x5 grid display
- **TopicEditorView**: Interface for adding/managing topics

## Usage

### iOS App
1. Open `BingoApp.xcodeproj` in Xcode
2. Build and run on iOS Simulator or device (iOS 16+ required)
3. The app starts with 30 sample topics pre-loaded
4. Tap **"Topics"** to add your own topics:
   - Enter one topic per line in the text editor
   - View current topics in the list below
   - Delete individual topics if needed
   - Tap **"Done"** to save changes
5. Tap **"New Game"** to generate a fresh random 5x5 bingo card
6. Tap tiles to check off completed activities
7. Get 4 in a row (horizontal, vertical, or diagonal) to win! 🎉
8. Use **"Reset Card"** to uncheck all tiles without generating new topics

### Swift Package
The core functionality is also available as a Swift Package:

```swift
import BingoCore

let topicManager = TopicManager()
topicManager.addTopics(from: "Topic 1\nTopic 2\nTopic 3")

let bingoCard = BingoCard()
bingoCard.generateCard(from: topicManager.topics)

// Check a tile
bingoCard.toggleTile(at: 0, col: 0)

// Check if won
if bingoCard.hasWon {
    print("Bingo! You won!")
}
```

## Testing

Run the unit tests to verify functionality:

```bash
swift test
```

All tests should pass, covering:
- Topic creation and management
- Bingo card generation
- Win condition detection

## Example Topics

The app comes with 30 sample topics including:
- Read a book
- Go for a walk
- Cook a meal
- Watch a movie
- Call a friend
- Exercise
- Listen to music
- Learn something new
- Try a new restaurant
- Go hiking
- And 20 more...

## Win Conditions

You win by getting **4 consecutive checked tiles** in any of these patterns:
- **Horizontal**: Any row with 4 in a row
- **Vertical**: Any column with 4 in a row  
- **Diagonal**: Main diagonal (top-left to bottom-right) with 4 in a row
- **Anti-diagonal**: Anti diagonal (top-right to bottom-left) with 4 in a row

Note: Unlike traditional bingo which requires 5 in a row, this version uses 4 in a row to make games more achievable and fun!

## Requirements

- **iOS**: 16.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+

## License

MIT License - see [LICENSE](LICENSE) file for details.