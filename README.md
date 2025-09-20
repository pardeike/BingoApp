# BingoApp

A SwiftUI iOS app that generates random 5x5 bingo cards from custom topics. Users can submit their own list of topics (one per row) and play bingo by checking off completed items. Get 4 in a row to win! 🎉

## Features

- 📝 **Custom Topic Management**: Add and manage your own bingo topics
- 🎯 **5x5 Bingo Card Generation**: Creates random bingo cards from your topics
- ✅ **Interactive Tiles**: Tap tiles to check them off as you complete activities
- 🏆 **Win Detection**: Automatically detects when you get 4 in a row (horizontal, vertical, or diagonal)
- 🔄 **New Game Function**: Generate fresh random cards anytime
- 🤖 **AI Topic Generation**: Use OpenAI to generate topic lists from descriptions
- 🔤 **AI Topic Shortening**: Automatically shorten long topics into concise phrases
- 🌍 **Multi-language Support**: AI features support English, German, and Swedish
- 🔐 **Secure API Key Storage**: OpenAI API keys are stored securely in the iOS keychain
- 💾 **Data Persistence**: Topics and game state are automatically saved
- 📱 **Modern iOS Interface**: Built with SwiftUI for iOS 16+

## OpenAI Integration

The app includes optional OpenAI integration for two main features:

### AI Topic Generation
Generate bingo topics automatically using AI:
1. In the topic editor, enter a description of what kind of topics you want
2. Tap **"Generate Topics"** 
3. AI will create a list of relevant bingo topics for you

### AI Topic Shortening  
Automatically shorten long topic descriptions into concise bingo-friendly phrases:
1. Add your OpenAI API key in the topic editor
2. Enter your topics (can be long descriptions)
3. Select your preferred language (English, German, or Swedish)
4. Tap **"Convert Topics to Short Titles"**
5. AI will convert topics like "Read a really long book about history" → "Read Book"

### API Key Setup:
- Get an API key from [OpenAI](https://platform.openai.com/api-keys)
- In the app, go to Configure Topics → paste your API key → Save
- Your key is stored securely in the iOS keychain
- Uses GPT-3.5-turbo for cost-effective processing

## Demo

The repository includes a console demo script that demonstrates the core functionality:

```bash
swift Demo.swift
```

The demo will:
- Load 30 sample topics
- Generate a random 5x5 bingo card
- Display the card in ASCII format
- Simulate checking off tiles to demonstrate win detection
- Show a winning scenario with 4 in a row

## Project Structure

```
BingoApp/
├── BingoApp.xcodeproj/             # Xcode project file
├── BingoApp/                       # iOS SwiftUI App
│   ├── Main.swift                  # App entry point
│   ├── ContentView.swift           # Main app interface
│   ├── BingoCardView.swift         # 5x5 bingo card display
│   ├── TopicEditorView.swift       # Topic management interface
│   ├── BingoTopic.swift            # Topic data model and manager
│   ├── BingoCard.swift             # Bingo card logic
│   ├── TopicTranslationService.swift # AI topic generation/translation
│   ├── OpenAIKeyStore.swift        # Secure API key storage
│   ├── TopicPersistence.swift      # Topic data persistence
│   ├── BingoCardPersistence.swift  # Game state persistence
│   └── Assets.xcassets/            # App icons and assets
├── Demo.swift                      # Console demo script
└── Package.swift                   # Dependency management configuration
```

## Core Components

The app is built with SwiftUI and uses the following key components:

- **TopicManager**: Manages the collection of bingo topics with persistence
- **BingoCard**: Handles 5x5 bingo card logic and win detection  
- **TopicTranslationService**: Provides AI-powered topic generation and multi-language support
- **OpenAIKeyStore**: Securely stores OpenAI API keys in the iOS keychain

## Usage

### iOS App
1. Open `BingoApp.xcodeproj` in Xcode
2. Build and run on iOS Simulator or device (iOS 16+ required)
3. The app starts with an empty topic list - you'll need to add your own topics
4. Tap **"Configure Topics"** to add your own topics:
   - Enter one topic per line in the text editor
   - Use **"Generate Topics"** to create topics with AI assistance
   - Use **"Convert Topics to Short Titles"** to shorten existing topics
   - View current topics in the list below
   - Delete individual topics if needed
   - Tap **"Done"** to save changes
5. Tap **"New Game"** to generate a fresh random 5x5 bingo card
6. Tap tiles to check off completed activities
7. Get 4 in a row (horizontal, vertical, or diagonal) to win! 🎉

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
