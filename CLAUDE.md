# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Gaslight is an iOS journaling app built with SwiftUI. It provides a simple interface for users to write and save journal entries with a clean, minimalist design.

## Architecture

- **Main App**: `GaslightApp.swift` - Standard SwiftUI app entry point using `@main`
- **Primary View**: `ContentView.swift` - Contains the main journaling interface with text editor and save functionality
- **UI Framework**: SwiftUI with NavigationView structure
- **State Management**: Uses `@State` for local component state (journal text, save confirmation messages)

## Development Commands

This is an Xcode project that uses Swift Package Manager. Common development tasks:

### Building and Running
- Open `Gaslight.xcodeproj` in Xcode
- Build: `Cmd+B` or Product → Build
- Run: `Cmd+R` or Product → Run
- Run on specific simulator: Select device from scheme dropdown

### Testing
- **Unit Tests**: Located in `GaslightTests/` using the Swift Testing framework
  - Run: `Cmd+U` or Product → Test
  - Individual test: Use the diamond icons in the editor gutter
- **UI Tests**: Located in `GaslightUITests/` using XCTest framework
  - Includes launch performance testing

### Project Structure
```
Gaslight/
├── Gaslight.xcodeproj/          # Xcode project file
├── Gaslight/                    # Main app source
│   ├── GaslightApp.swift       # App entry point
│   ├── ContentView.swift       # Main journal interface
│   └── Assets.xcassets/        # App icons and assets
├── GaslightTests/              # Unit tests (Swift Testing)
└── GaslightUITests/            # UI tests (XCTest)
```

### Target Information
- **Main Target**: Gaslight (iOS app)
- **Deployment Target**: iOS 18.5+
- **Swift Version**: 5.0
- **Bundle ID**: sumcow.Gaslight
- **Supported Devices**: iPhone and iPad (Universal)

## Key Implementation Details

- Journal text is stored in `@State private var journalText: String`
- Save functionality currently shows a confirmation message but doesn't persist data
- Uses `TextEditor` for multi-line text input with custom styling
- Navigation structure uses `NavigationView` with title "Journal"
- Save confirmation uses `DispatchQueue.main.asyncAfter` for auto-dismissal

## Development Notes

- The app currently has placeholder save functionality - entries are not persisted
- UI uses standard iOS design patterns with rounded corners and system colors
- SwiftUI previews should work for rapid UI development
- Asset catalog includes standard app icon and accent color configurations