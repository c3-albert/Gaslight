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
- **AI System**: Groq API integration with creative prompting engine and secure Keychain storage

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
├── Gaslight/                    # Main app source (18 Swift files)
│   ├── GaslightApp.swift       # App entry point with SwiftData
│   ├── ContentView.swift       # Main writing interface with typewriter
│   ├── MainTabView.swift       # Tab navigation controller
│   ├── NewEntriesListView.swift # Card-based entry browser ⭐ ACTIVE
│   ├── HomeView.swift          # Home/landing view
│   ├── SettingsView.swift      # App settings & AI mode selection
│   ├── CalendarView.swift      # Calendar-based entry browsing
│   ├── CustomCalendarView.swift # Custom calendar component
│   ├── EditEntryView.swift     # Entry editing interface
│   ├── WriteForMeView.swift    # AI text continuation with typewriter
│   ├── ExploreAIView.swift     # AI exploration interface
│   ├── JournalEntry.swift      # SwiftData model
│   ├── EntryType.swift         # Entry classification enum with theme colors
│   ├── TypewriterText.swift    # Typewriter animation utilities ✨
│   ├── HighlightedText.swift   # Text highlighting utilities
│   ├── AIEntryGenerator.swift  # Legacy template-based AI system
│   ├── GroqAIGenerator.swift   # Modern Groq API integration ⭐ PRIMARY
│   ├── KeychainManager.swift   # Secure API key storage
│   ├── Gaslight.entitlements   # App capabilities
│   └── Assets.xcassets/        # App icons and assets
├── GaslightTests/              # Unit tests
├── GaslightUITests/            # UI tests
├── Tests/                      # Development test utilities
│   ├── test_gpt2_*.swift      # Legacy GPT-2 testing scripts
│   ├── test_procedural_prompts.swift # Prompt testing utilities
│   ├── batch_test_entries.md   # Automated testing instructions
│   └── create_test_entries.md  # Step-by-step testing guide
├── README.md                   # Claude Code learning journey documentation
└── CLAUDE.md                   # This file - development guidance
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
- **Groq API**: High-quality, fast AI generation using cloud-based LLMs
- **Multiple Models**: Mixtral, Llama 3 70B/8B, Gemma for different use cases
- **Secure Storage**: API keys stored in iOS Keychain with hardware encryption

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
- **Groq Integration**: Real-time API calls with progress tracking and error handling

## Groq AI Testing Instructions

### **Quick Test (5 minutes)**
1. **Configure API Key**: Settings → AI Engine → Add your Groq API key from console.groq.com
2. **Test Connection**: Tap "Test Connection" to verify setup
3. **Generate Test Entries**: Tap "Generate Test Entry" 5+ times to see variety
4. **Compare Results**: Check Entries tab for unique, high-quality content

### **Comprehensive Creative Testing (15 minutes)**
1. **Reality Level Testing:**
   - Low Reality (10-30%): Creative, imaginative, surreal content
   - Medium Reality (40-60%): Balanced realistic/creative mix
   - High Reality (70-90%): Grounded, realistic experiences

2. **Model Comparison:**
   - Llama 3.1 8B: Fast generation, high quality
   - Llama 3.3 70B: Most sophisticated and nuanced

3. **Prompt Variety Testing:**
   - Generate 10+ entries at same reality level
   - Verify each entry uses different creative approaches
   - Check for narrative perspective variations

### **Expected Results**
- **Low Reality**: "Write about a moment when the ordinary world felt slightly different than usual..."
- **High Reality**: "Write about the practical challenges and small victories of your recent days..."
- **Creative Variety**: Each generation uses different prompting dimensions for unique content

### **Success Indicators**
✅ **Creative Variety**: No two entries feel repetitive or template-like  
✅ **Reality Intelligence**: Content appropriately adapts to creativity settings  
✅ **Quality Consistency**: All entries feel natural and human-like  
✅ **Performance**: Reliable 2-3 second generation with proper error handling  

## Development Notes

### **Recent Major Updates**
- ✅ **Enhanced Creative Prompting System**: Implemented advanced prompt generation with multiple creative dimensions
- ✅ **Groq API Integration**: Complete replacement of template system with high-quality LLM generation
- ✅ **Secure Keychain Storage**: Professional-grade API key management with hardware encryption
- ✅ **Reality-Level Adaptive Prompting**: Intelligent prompt selection based on creativity vs realism settings
- ✅ **Multi-Dimensional Prompt Generation**: Creative approaches, narrative perspectives, temporal contexts, and emotional frameworks
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
- **Groq Generation**: Natural, contextual, human-like journal entries
- **Creative Variety**: 10+ prompt dimensions ensuring unique content every time
- **Style Adaptation**: Matches user's writing patterns and thematic preferences
- **Performance**: Consistent 2-3 second generation times with high reliability
- **Model Selection**: Llama 3.1 8B (fast) and Llama 3.3 70B (sophisticated)

### **Future Development**
- ✅ **Creative Prompting System**: COMPLETED - Implemented multi-dimensional prompt generation
  - Added 5 creative approach categories with 5 variations each
  - Implemented narrative perspective, temporal context, and emotional framework selection
  - Created reality-level adaptive style guidance with sensory, rhythm, imagery, and tone elements
  - Enhanced contextual prompts with creative twists and framework variations
  - Location: `GroqAIGenerator.swift:218-420` creative prompt generation system
- **Model Management**: User-selectable Groq model types (8B instant vs 70B versatile)
- **Advanced AI Features**: Context-aware generation, mood analysis, writing style adaptation
- **Performance Optimization**: Caching, rate limiting, batch processing techniques

### **Testing Resources**
The repository includes comprehensive testing documentation and utilities:

- **`Tests/create_test_entries.md`**: Step-by-step manual testing guide updated for Groq API testing
- **`Tests/batch_test_entries.md`**: Quick automated testing using built-in Settings features
- **Built-in App Testing**: Settings → Testing section with "Generate Test Entry" buttons
- **Reality Level Testing**: Systematic testing across creative/realistic spectrum
- **Model Comparison**: Built-in tools to test different Groq models (8B vs 70B)
- **Prompt Variation Testing**: Custom prompt import for systematic quality evaluation

### **Debugging Tips**
- **Console Logs**: Look for "✅ Groq connection successful" and token usage stats
- **API Status**: Check Settings → AI Engine → Groq API Key status and Test Connection
- **Error Handling**: Comprehensive error messages for network, auth, and rate limit issues
- **Network Requirements**: Requires stable internet connection for all AI generation
- **File Structure**: `NewEntriesListView` is the active entry browser, legacy views removed
- **Testing Verification**: Use Settings → Testing → "Generate Test Entry" for quick validation

### **Repository Status**
- **Total Swift Files**: 18 (2,800+ lines total)
- **AI Integration**: Groq API with secure Keychain storage and creative prompting engine
- **Latest Features**: Enhanced creative prompting system with multi-dimensional variety
- **Documentation**: Updated testing guides for Groq API integration, organized test utilities
- **Build Status**: Successfully builds and runs on iOS 18.5+ simulator
- **Code Quality**: Legacy code removed, test files organized in dedicated Tests/ directory
- **Key Features**: Production-ready AI generation with professional security and creative variety

## Development Session Log

### Latest Development Activities (August 2025)
- **COMPLETED**: Enhanced creative prompting system with multi-dimensional variety
- **COMPLETED**: Implemented advanced prompt generation engine in GroqAIGenerator
- **COMPLETED**: Added reality-level adaptive prompting with 5+ creative dimensions
- **COMPLETED**: Created contextual framework selection and creative twist generation
- **COMPLETED**: Built comprehensive style guidance system (sensory, rhythm, imagery, tone)
- **COMPLETED**: Legacy code cleanup - removed unused EntriesListView.swift (69 lines)
- **COMPLETED**: Repository organization - moved test files to dedicated Tests/ directory
- **COMPLETED**: Updated project documentation to reflect clean architecture
- **QUALITY IMPROVEMENTS**: Now generates unique, varied content every time
- **TESTING**: Comprehensive build verification and prompt variety validation
- **BUILD STATUS**: ✅ Successfully builds and runs after cleanup (verified iPhone 16 simulator)

### Creative Prompting Enhancement Details
- **Multi-Dimensional Generation**: 5 creative approaches × 6 narrative perspectives × 6 temporal contexts × 5+ emotional frameworks
- **Reality-Level Intelligence**: Adaptive prompting from surreal/creative (low) to realistic/grounded (high)
- **Style Guidance System**: Randomized selection of sensory, rhythm, imagery, and tone guidance
- **Contextual Frameworks**: 6 different approaches for building on recent writing patterns
- **Creative Twists**: Reality-level specific variations to prevent repetitive content
- make sure todo is accurately reflected in memory, so we can continue where we left off in the next session.

add to todo: research if groq is blocked in parts of the world, like china, and check for alternative solutions in those regions.