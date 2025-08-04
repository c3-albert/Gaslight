# Gaslight 🔥

A SwiftUI-based iOS journaling app that blends reality with AI-generated content, allowing users to explore the boundaries between truth and fiction in their personal narratives.

## Features

### Core Functionality
- **AI-Enhanced Journaling**: Write journal entries with AI assistance that can modify or extend your thoughts
- **Reality Level Control**: Adjust how much AI influence you want in your entries (from 100% real to pure AI generation)
- **Time Travel Writing**: Write entries for past or future dates using the integrated date/time picker
- **Smart Entry Management**: Card-based entry view with automatic scrolling to your most recent entries

### AI Capabilities
- **Edit for Me**: AI modifies your existing text while maintaining your voice
- **Write for Me**: AI generates additional content to continue your thoughts
- **Template-Based Generation**: Uses sophisticated templates for realistic and creative content generation
- **Reality Indicators**: Visual cues showing the "reality level" of each entry

### User Experience
- **Modern SwiftUI Interface**: Clean, intuitive design following iOS design patterns
- **Light/Dark Mode**: Automatic theme switching support
- **Calendar Integration**: Visual calendar view for browsing entries by date
- **Entry History**: Comprehensive list view with smart grouping by date
- **Persistent Storage**: Uses SwiftData for reliable local data storage

## Technical Details

### Architecture
- **SwiftUI + SwiftData**: Modern iOS development stack with reactive UI and persistent storage
- **MVVM Pattern**: Clean separation of concerns with observable objects
- **Template-Based AI**: Phase 1 implementation using sophisticated text templates (Core ML integration planned for future)

### Key Components
- `ContentView`: Main writing interface with AI controls
- `NewEntriesListView`: Card-based entry browser with smart scrolling
- `AIEntryGenerator`: Template-based text generation system
- `JournalEntry`: SwiftData model for persistent storage
- `SettingsView`: App configuration and testing tools

### Development Features
- **Comprehensive Testing**: Unit and UI test suites included
- **Bulk Data Generation**: Built-in tools for generating test data
- **Development Documentation**: Detailed CLAUDE.md with development history

## Getting Started

### Requirements
- iOS 18.5+
- Xcode 16.4+
- Swift 5.0+

### Installation
1. Clone this repository
2. Open `Gaslight.xcodeproj` in Xcode
3. Build and run on your device or simulator

### Usage
1. **Write an Entry**: Tap the text editor and start writing
2. **Choose Your Reality**: Use the Reality Level slider to control AI influence
3. **AI Assistance**: Use "Edit for Me" to modify text or "Write for Me" to extend it
4. **Time Travel**: Tap the date selector to write entries for different times
5. **Browse History**: Switch to the entries tab to view and manage your journal

## Development Philosophy

Gaslight explores the intersection of human creativity and artificial intelligence in personal reflection. The app is designed to:

- **Question Reality**: What happens when we can't distinguish between our real thoughts and AI-generated ones?
- **Enhance Creativity**: Use AI as a collaborative partner in self-expression
- **Preserve Authenticity**: Always maintain the option to keep entries completely human-written
- **Encourage Reflection**: Provide tools for deeper self-examination and creative writing

## Future Roadmap

- **Core ML Integration**: Replace template system with on-device language models
- **Advanced AI Features**: More sophisticated text generation and editing
- **Export Capabilities**: Share entries in various formats
- **Collaboration Features**: Share entries with friends while maintaining privacy
- **Analytics**: Insights into writing patterns and AI usage

## Contributing

This project was developed with assistance from Claude AI. Contributions are welcome! Please feel free to:

- Report bugs or suggest features via Issues
- Submit pull requests with improvements
- Share feedback on the user experience
- Contribute to the AI generation templates

## License

[Add your preferred license here]

## Acknowledgments

- Built with SwiftUI and SwiftData
- AI assistance provided by Claude (Anthropic)
- Developed using Claude Code for iterative development

---

*"The truth is not always beautiful, nor beautiful words the truth." - Laozi*

*Gaslight helps you explore the beautiful ambiguity between truth and fiction in your personal narratives.*