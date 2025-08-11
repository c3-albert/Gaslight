# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Gaslight is a sophisticated iOS journaling app that blends reality with AI-generated content. Users can write journal entries with AI assistance that can modify, enhance, or extend their thoughts using multiple AI generation modes.

**Core Concept**: "Too lazy to journal regularly? Let AI gaslight you into thinking you wrote more entries than you actually did."

## Current Architecture (v2.0)

### **Core Components**
- **Main App**: `GaslightApp.swift` - SwiftUI app entry point with SwiftData integration
- **Primary Views**: 
  - `ContentView.swift` - Main writing interface with AI controls and date/time picker
  - `MainTabView.swift` - Tab-based navigation (Write, Entries, Calendar, Settings)
  - `NewEntriesListView.swift` - Card-based entry browser with smart auto-scroll
- **Data Layer**: SwiftData with `JournalEntry` model and persistent storage
- **AI System**: Three-mode AI integration (Templates, Core ML, Hybrid)

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
├── Gaslight/                    # Main app source (15 Swift files)
│   ├── GaslightApp.swift       # App entry point with SwiftData (44 lines)
│   ├── ContentView.swift       # Main writing interface with typewriter (375 lines)
│   ├── MainTabView.swift       # Tab navigation controller (74 lines)
│   ├── NewEntriesListView.swift # Card-based entry browser (368 lines) ⭐ ACTIVE
│   ├── EntriesListView.swift   # Legacy entry view (69 lines) - UNUSED
│   ├── SettingsView.swift      # App settings & AI mode selection (293 lines)
│   ├── CalendarView.swift      # Calendar-based entry browsing (195 lines)
│   ├── CustomCalendarView.swift # Custom calendar component (277 lines)
│   ├── EditEntryView.swift     # Entry editing interface (108 lines)
│   ├── WriteForMeView.swift    # AI text continuation with typewriter (209 lines)
│   ├── JournalEntry.swift      # SwiftData model (80 lines)
│   ├── EntryType.swift         # Entry classification enum with theme colors (47 lines)
│   ├── TypewriterText.swift    # Typewriter animation utilities (119 lines) ✨ NEW
│   ├── AIEntryGenerator.swift  # Template-based AI system (238 lines)
│   ├── CoreMLTextGenerator.swift # On-device AI integration (161 lines)
│   ├── gpt2-512.mlmodel        # 645MB GPT-2 Core ML model
│   ├── Gaslight.entitlements   # App capabilities
│   └── Assets.xcassets/        # App icons and assets
├── GaslightTests/              # Unit tests
├── GaslightUITests/            # UI tests
├── README.md                   # Claude Code learning journey documentation
├── CLAUDE.md                   # This file - development guidance
├── AIModeTester.swift          # Testing utility for AI mode comparison
├── test_ai_output.swift        # Quick AI output testing script
├── test_core_ml.md             # Core ML testing documentation
├── create_test_entries.md      # Step-by-step testing guide
├── batch_test_entries.md       # Automated testing instructions
└── ai_mode_comparison_report.md # Generated comparison report
```

### Target Information
- **Main Target**: Gaslight (iOS app)
- **Deployment Target**: iOS 18.5+
- **Swift Version**: 5.0
- **Bundle ID**: sumcow.Gaslight
- **Supported Devices**: iPhone and iPad (Universal)

## Key Implementation Details

### **Data Persistence**
- **SwiftData Integration**: Full persistence with `JournalEntry` model
- **Entry Types**: `.userWritten`, `.aiGenerated`, `.aiEnhanced`
- **Reality Levels**: 0.0-1.0 scale for AI influence control
- **Timestamps**: Custom date/time selection for past/future entries

### **AI Generation System**
- **Templates Mode**: Fast, whimsical generation using template variables
- **Core ML Mode**: On-device GPT-2 model (645MB) for sophisticated text
- **Hybrid Mode**: Intelligent switching based on reality level (<50% = Core ML, ≥50% = Templates)

### **User Interface**
- **Tab Navigation**: Write, Entries, Calendar, Settings with smart badges and haptic feedback
- **Card-based Entry Display**: With AI type indicators and action buttons
- **Date/Time Picker**: Write entries for any date/time with orange highlighting for non-current dates
- **Reality Level Slider**: Blue-to-orange gradient slider with haptic feedback at thresholds
- **Dual AI Buttons**: "Edit for Me" (modify existing) + "Write for Me" (extend text)
- **Blue/Orange Theme**: Consistent color coding throughout the app (blue = real/human, orange = AI-generated)

### **Technical Architecture**
- **Async/Await**: All AI generation uses modern concurrency
- **@MainActor**: Thread-safe UI updates
- **Observable Objects**: Reactive state management
- **Core ML Integration**: On-demand model loading with progress tracking

## Core ML Testing Instructions

### **Quick Test (5 minutes)**
1. **Open Gaslight app**
2. **Go to Settings** → Testing section  
3. **Test each AI mode:**
   - Set "Templates Only" → Tap "Generate Test Entry" 3 times
   - Set "Core ML Only" → Tap "Load GPT-2 Model" → Generate 3 entries
   - Set "Hybrid Mode" → Generate 3 entries
4. **Compare results** in Entries tab

### **Comprehensive Test (15 minutes)**
1. **Create identical test prompts** in each mode:
   - "Today I woke up feeling"
   - "Something unexpected happened when I"
   - "I've been thinking about"

2. **Test Templates Mode:**
   - Settings → "Templates Only"
   - Use prompts above with different reality levels
   - Note instant generation

3. **Test Core ML Mode:**
   - Settings → "Core ML Only" 
   - Tap "Load GPT-2 Model" (wait 10-30 seconds)
   - Use same prompts
   - Note 2-3 second processing delay

4. **Test Hybrid Mode:**
   - Settings → "Hybrid Mode"
   - Test low reality (10%) → should use Core ML style
   - Test high reality (90%) → should use Templates style

### **Expected Results**
- **Templates**: "My coffee mug started giving me relationship advice"
- **Core ML**: "The weight of this realization settled over me like a familiar blanket. There's something profoundly human about recognizing patterns in chaos..."
- **Hybrid**: Intelligently switches based on reality level

### **Success Indicators**
✅ Quality gap: Core ML produces more sophisticated, introspective content  
✅ Performance: Core ML shows processing delay, Templates are instant  
✅ Intelligence: Hybrid adapts to reality level setting  
✅ Reliability: Graceful fallback when Core ML fails  

## Development Notes

### **Recent Major Updates**
- ✅ **Procedural Prompt Generation**: Replaced static prompts with 4-factor entropy system
- **Core ML Integration**: Re-enabled loading with graceful fallback when model missing  
- **Three AI Modes**: Templates (fast), Core ML (thoughtful), Hybrid (intelligent)
- **Blue/Orange Theme System**: Comprehensive color coding throughout the app
- **Typewriter Animation**: ChatGPT-style character-by-character text streaming for AI generation
- **Enhanced UX**: Progress bars, loading states, model management, haptic feedback
- **Async Architecture**: Modern Swift concurrency throughout

### **Blue/Orange Theme Implementation**
- **Color Philosophy**: Blue represents real/human content, Orange represents AI-generated content
- **Comprehensive Coverage**: Applied consistently across all UI elements
- **Key Components**:
  - **Reality Slider**: Orange-to-blue gradient background with white slider handle
  - **Entry Cards**: Color-coded top borders, type indicators, and action buttons
  - **Tab Badges**: Show reality level percentage with appropriate colors
  - **Calendar View**: Blue/orange highlighting for days with different entry types
  - **Date Picker**: Orange highlight when writing for non-current dates
  - **Type Indicators**: Replaced emojis with colored circles throughout
  - **Action Buttons**: Blue for "Edit" buttons, orange for AI "Write for Me" buttons
- **Technical Details**:
  - **EntryType.swift**: Added `themeColor` property for consistent color mapping
  - **Haptic Feedback**: Reality slider provides tactile feedback at key thresholds
  - **Split Calendar Display**: Days with both real and AI entries show triangular split colors
  - **Dynamic Styling**: Colors adjust based on entry type and reality level percentages

### **Typewriter Animation System**
- **ChatGPT-Style Streaming**: Character-by-character text animation during AI generation
- **Comprehensive Integration**: Applied to both main ContentView and WriteForMeView AI functions
- **Visual Effects**:
  - **Orange Tint Overlay**: Entire screen gets subtle orange tint during AI generation
  - **Orange Border**: Text areas show orange border highlighting during animation
  - **Loading States**: Buttons display progress indicators and "AI Writing..." text
  - **Disabled Interaction**: Text fields disabled during generation to prevent conflicts
- **Technical Implementation**:
  - **TypewriterText.swift**: Reusable SwiftUI component with configurable speed
  - **TypewriterViewModel**: Observable class for managing streaming state
  - **Async Animation**: Uses Task-based concurrency with natural timing variations
  - **Speed Control**: Default 0.03s per character with randomized variance for natural feel
  - **Cancellable Tasks**: Proper cleanup when users navigate away
- **Performance Features**:
  - **Natural Timing**: Slight randomness in character delays for authentic typewriter feel
  - **Memory Efficient**: Streams characters without storing intermediate states
  - **Thread Safe**: All UI updates properly dispatched to MainActor
  - **Graceful Completion**: Smooth transition from animation to final editable text

### **AI Content Quality**
- **Templates**: Whimsical, absurdist, object-based humor
- **Core ML**: Deep, philosophical, introspective, journal-like
- **Performance**: Templates = instant, Core ML = 2-3 seconds

### **Future Development**
- ✅ **GPT-2 Prompt Optimization**: COMPLETED - Implemented procedural prompt generation system
  - Replaced static prompts with 4-factor seed system (date, device, launch count, battery)
  - Added modular component pools for characters, settings, actions, discoveries, starters, moods
  - Reality-level adaptive prompts with weighted pools for fantastical vs whimsical content
  - Generates ~10^12 unique prompt combinations for maximum variety
  - Location: `AIEntryGenerator.swift:269-419` procedural generation system
- **Model Management**: User-selectable model sizes and types  
- **Advanced AI Features**: Context-aware generation, mood analysis
- **Performance Optimization**: Model caching, quantization techniques

### **Testing Resources**
The repository includes comprehensive testing documentation and utilities:

- **`create_test_entries.md`**: Step-by-step manual testing guide (15 min comprehensive test)
- **`batch_test_entries.md`**: Quick automated testing using built-in Settings features
- **`test_core_ml.md`**: Core ML-specific testing documentation  
- **`AIModeTester.swift`**: Utility script for generating comparison reports
- **`test_ai_output.swift`**: Quick script to verify AI output differences
- **Built-in App Testing**: Settings → Testing section with "Generate Test Entry" buttons

### **Debugging Tips**
- **Console Logs**: Look for "✅ Core ML GPT-2 model loaded successfully"
- **Model Status**: Check Settings → AI Engine → Core ML Model Status
- **Fallback Behavior**: Core ML failures automatically use Templates
- **Memory Usage**: Core ML adds ~650MB when loaded
- **File Structure**: `NewEntriesListView` is active, `EntriesListView` is legacy/unused
- **Testing Verification**: Use Settings → Testing → "Generate Test Entry" for quick validation

### **Repository Status**
- **Total Swift Files**: 15 (2,442+ lines total)
- **Core ML Model**: 645MB gpt2-512.mlmodel included in bundle
- **Latest Features**: Typewriter animation system with ChatGPT-style streaming
- **Documentation**: Comprehensive testing guides and learning journey README
- **Build Status**: Successfully builds and runs on iOS 18.5+ simulator
- **Key Features**: All major functionality implemented and tested, including advanced UI animations

## Development Session Log

### Today's Development Activities
- Continued work on Gaslight iOS journaling app
- Enhanced Typewriter Animation system
- Refined Core ML text generation integration
- Updated project documentation and testing resources
- **try again**
- add todos:

* fix floating button UI for new journal entry, should be MUCH closer to the bottom of the screen, so it doesn't block anything valuable on the screen
* fix logic for "edit for me" or completely remove
* more robust options of displaying calendar, like day/week/month/year instead of just month.
* remove slider on the top of the calendar. only have a legend to indicate if any day was ai generated or user written.
* re-examine logic for generated content. journal should be able to suggest entries based on previous entries after X amount of "real" entries on the home page