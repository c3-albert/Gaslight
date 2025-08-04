# Gaslight 🔥
## A Claude Code Learning Journey: From Idea to iOS App

*"I was too lazy to write journal entries every day, so I thought it would be funny to gaslight myself into thinking I was writing more than I actually was."*

This project documents my journey from complete beginner to functional iOS app using Claude Code.

Disclaimer: Some of the content below is AI-generated. (Bullet points are generally Claude suggestions that were kept in this draft.)

---

## The Origin Story

I want to journal more regularly, but I'm too lazy/forgetful to write as often as I should. I wanted an app that would gaslight me into thinking I'd written more than I actually had. I decided to use Claude to get started, since it seemed most compatible with working on command line, and would get me from zero-to-something quickly.

I had no prior experience with iOS development or Claude until starting this project.

## What This Project Demonstrates

This isn't a showcase of expertise - it's documentation of a learning process. Through building Gaslight, I discovered practical insights about Claude Code workflows, iOS development patterns, and AI-assisted programming that could benefit other developers starting similar journeys. I still consider myself a very beginner user of Claude.

---

## Key Insights for Other Claude Code Beginners

* Definitely keep message limits in mind. It's important to keep your responses efficient. It's okay to press `esc` occasionally if you forgot something in your prompt, or if you remembered some other critical information.
* Claude may not necessarily consider large architectural until later, so it can be helpful to speak about the scale of your project before you start!
* I was very flattered initially from Claude's feedback about my idea ("What a fun, unique, and innovative idea!") I prompted Claude to try and be more neutral and honest about its opinion. Not sure if the efficacy of my responses improved afterwards, but I appreciate a more objective approach Claude seems to have now.
* While it's good to ask for as much as you can in one go to be efficient, I found that requesting too many features at once tended to introduce bugs and issues that were hard to identify. I think it's best to still iterate deliberately in the process and test features one-by-one.

### Specific Prompt Patterns That Worked

- **For debugging:** "Here's the error [screenshot], here's what I was doing, what's the most likely cause?"
- **For decisions:** "I need to choose between X and Y. What are the trade-offs for a learning project?"
- **For planning:** "Before we implement this feature, what should I consider about the current architecture?"

---

## Claude Code Learning Journey

### Starting Point
- **iOS Experience:** None
- **Claude Code Experience:** None  
- **SwiftUI Knowledge:** Zero
- **AI Integration Experience:** Completely new territory

### What I Learned About Effective Claude Code Usage

#### Early Mistakes
- **Giving too much freedom:** "Build me an iOS journaling app" led to overwhelming responses
- **Poor context management:** Jumping between topics without proper setup
- **Unilateral decision making:** I didn't ask Claude for alternatives or suggestions, something that didn't occur to me until later on in the process.

#### Learning more
- **Screenshot debugging:** Uploading console errors and UI screenshots accelerated problem-solving dramatically
- **Planning phases:** Learning to separate "what should we build?" from "how do we build it?"
- **Collaborative decision-making:** Asking "what are the trade-offs?" instead of "just do X"

#### Advanced Workflow Optimizations
- **Visual verification:** Using obvious UI changes to confirm code was actually running (for example, adding background colors to individual elements to see if they were displaying or even rendering)
- **Systematic debugging:** Developing reproducible approaches to cache/build issues
- **Context preservation:** Learning to maintain project context across long development sessions

### Message Limit Management
**Challenge:** Hitting message limits while "in the groove" of development  
**Current Approach:** Better upfront planning to make each message more effective  
**Still Working On:** Batching related questions, using screenshots more efficiently

Overall takeaways: use Claude more efficiently to handle more than one task at once, so that I don't have to waste responses.

---

## Technical Exploration

### AI Integration Research
Through conversations with Claude, I explored different approaches for generating journal entries:

**Option 1: On-Device AI (Core ML)**
- Pros: Privacy, no API costs, works offline
- Cons: Complex setup, limited models, large app size
- Decision: Planned for Phase 2

**Option 2: Cloud APIs (OpenAI, etc.)**
- Pros: Powerful models, simple integration
- Cons: API costs, privacy concerns, network dependency
- Decision: Avoided for this learning project

**Option 3: Template-Based Generation**
- Pros: Immediate implementation, full control, no dependencies
- Cons: Limited creativity, requires manual templates
- Decision: Perfect starting point for learning

### Architecture Decisions Made with Claude
- **SwiftUI vs UIKit:** Chose SwiftUI for modern development patterns
- **SwiftData vs Core Data:** SwiftData for simpler learning curve
- **MVVM Pattern:** Clean separation recommended by Claude for maintainability

---

## Development Methodology Evolution

Putting in more thoughtful and structured prompts generally yielded better results. For example, asking Claude to "fix the issue" of build failure generally worked after a few tries, but pasting in error messages, attaching screenshots of broken UI, or asking Claude to write debugging print statements and examining them in the console later helped troubleshoot problems much faster, and required fewer responses.

Instead of
```
Me: "I'm not seeing the updated changes in the updated build"
Claude: *confused response*
```

A better response might be
```
Me: "I'm getting this SwiftUI compiler error [screenshot]. 
The app was working before I added the date picker. 
What's the most likely cause and how should I debug it?"
Claude: *targeted, actionable response*
```

### Collaborative Planning

It was also extremely useful to have Claude bounce ideas off of.

```
Me: "I want to add AI text generation. What are the trade-offs 
between different approaches for an iOS learning project? Create a list of pros and cons for each option that I can use, and potentially provide me with rough estimates of pricing options"
Claude: *comprehensive analysis with recommendations*
```

---

## Technical Implementation Highlights

### Features Built
- **AI-Enhanced Journaling:** Template-based text generation with reality level controls
- **Time Travel Writing:** Date/time picker for writing entries in past/future
- **Smart UI:** Card-based entry view with automatic scrolling to recent entries
- **Data Persistence:** SwiftData integration with proper model relationships
- **Modern iOS Patterns:** SwiftUI, MVVM, reactive state management

### Development Process Documentation
Every major feature includes commit messages showing the Claude Code collaboration process:
- Initial planning conversations
- Implementation iterations
- Debugging sessions
- Refinement based on testing

---

## What I'd Do Differently Next Time

### Better Message Management
- **Batch related questions** into single, well-structured prompts
- **Prepare screenshots** before starting debugging conversations
- **Plan conversation flow** to minimize context switching

### Improved Context Strategy
- **Start each session** with project state summary
- **Maintain focus** on one feature area at a time
- **Document decisions** for future reference

### Enhanced Learning Approach
- **Research phase first:** Understand iOS patterns before implementing
- **Prototype key decisions:** Test architecture choices early
- **Regular reflection:** Document lessons learned throughout process

---

## Future Learning Goals

### Immediate Next Steps
- **Advanced SwiftUI patterns:** Complex state management, custom modifiers
- **Better AI integration:** Explore Core ML for on-device text generation
- **iOS best practices:** Navigation, data flow, performance optimization

### Long-term Development
- **Claude Code mastery:** More sophisticated prompt engineering
- **iOS expertise:** Understanding platform-specific design patterns
- **AI application development:** Responsible AI integration practices

---

## Project Artifacts

### Documentation
- **CLAUDE.md:** Evolution of development guidance throughout project
- **Commit history:** Shows real-time Claude Code collaboration process
- **This README:** Learning journey documentation

### Technical Implementation
- **SwiftUI Architecture:** Modern iOS patterns learned through AI assistance
- **AI Integration:** Template-based generation as foundation for future enhancement
- **Development Workflow:** Reproducible process for iOS projects with Claude Code

---

## Why This Matters for Developer Education

This project demonstrates several key competencies relevant to AI-assisted development education:

1. **Systematic Learning Approach:** Documented progression from confusion to clarity
2. **Effective Collaboration with AI:** Evolved from poor to sophisticated prompting
3. **Real Problem-Solving:** Actual debugging, architecture decisions, and trade-offs
4. **Documentation Mindset:** Captured insights for future developers
5. **Honest Assessment:** Realistic view of capabilities and areas for growth

The goal isn't to showcase expertise, but to demonstrate the learning process that could help other developers navigate similar journeys with Claude Code.

---

## Technical Details

**Built With:** SwiftUI, SwiftData, iOS 18.5+  
**Development Environment:** Xcode 16.4, Claude Code for AI assistance  
**Architecture:** MVVM pattern with reactive state management  
**AI Integration:** Template-based text generation (Phase 1 of planned Core ML integration)

**Repository Structure:**
- Comprehensive commit history showing AI-assisted development process
- CLAUDE.md documenting evolving development practices
- Full test suite for learning iOS testing patterns

---

*Built by someone who had never touched iOS development before, with a lot of help from Claude Code, and a healthy dose of curiosity about what's possible when humans and AI collaborate on creative projects.*