//
//  HomeView.swift
//  Gaslight
//
//  Created by Albert Xu on 8/11/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdDate, order: .reverse)
    private var allEntries: [JournalEntry]
    
    @State private var suggestedEntry: String = ""
    @State private var isGeneratingEntry = false
    @State private var selectedTheme: GroqAIGenerator.ThemePrompts? = nil
    @StateObject private var groqGenerator = GroqAIGenerator.shared
    
    private var recentEntries: [JournalEntry] {
        // Analyze up to 60 entries (not exactly 60) - take what's available
        let maxEntries = min(60, allEntries.count)
        return Array(allEntries.prefix(maxEntries))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Good Morning")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                
                                Text("Ready to Write?")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            // Stats circle
                            VStack {
                                Text("\(allEntries.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("entries")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Circle().fill(Color.blue.opacity(0.1)))
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    
                    // Suggested journal entry card
                    SuggestedEntryCardView(
                        suggestedEntry: suggestedEntry,
                        isGenerating: isGeneratingEntry || groqGenerator.isGenerating,
                        generationProgress: groqGenerator.generationProgress,
                        onGenerate: generateSuggestedEntry,
                        onUse: useSuggestedEntry,
                        groqGenerator: groqGenerator
                    )
                    .padding(.horizontal)
                    
                    // Theme Sliders
                    ThemeSlidersView(groqGenerator: groqGenerator, onSliderChange: {
                        // Don't generate new entries on slider change - let user control generation
                    })
                    .padding(.horizontal)
                    
                    // Bottom spacing for floating button
                    Spacer()
                        .frame(height: 100)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                // Don't auto-generate entries on startup - let user control generation
            }
        }
    }
    
    private func generateSuggestedEntry() {
        guard !recentEntries.isEmpty else {
            suggestedEntry = "Write a few journal entries first, then tap 'Generate New' to get personalized AI suggestions!"
            return
        }
        
        isGeneratingEntry = true
        
        Task {
            do {
                let recentContent = extractRecentContent()
                let prompt = buildPersonalizedPrompt()
                
                let entry = try await groqGenerator.generateJournalEntryWithSliders(
                    prompt: prompt,
                    recentEntries: recentContent
                )
                
                await MainActor.run {
                    suggestedEntry = entry
                    isGeneratingEntry = false
                }
            } catch {
                await MainActor.run {
                    suggestedEntry = "Unable to generate entry. Please check your Groq API key in Settings."
                    isGeneratingEntry = false
                }
                print("❌ Failed to generate suggested entry: \(error)")
            }
        }
    }
    
    private func buildPersonalizedPrompt() -> String {
        let basePrompt = "Write a journal entry that feels authentic and personal."
        
        if recentEntries.isEmpty {
            return basePrompt
        }
        
        // Analyze user's writing patterns
        let styleAnalysis = analyzeWritingStyle()
        
        var prompt = basePrompt
        prompt += " " + styleAnalysis
        
        return prompt
    }
    
    private func analyzeWritingStyle() -> String {
        let contents = recentEntries.map { $0.content }
        let totalWords = contents.joined().split(separator: " ").count
        let averageLength = totalWords / max(contents.count, 1)
        
        // Analyze emotional tone
        let emotionalWords = ["feel", "felt", "happy", "sad", "excited", "worried", "grateful", "frustrated", "peaceful", "anxious"]
        let emotionalContent = contents.contains { entry in
            emotionalWords.contains { entry.lowercased().contains($0) }
        }
        
        // Analyze writing style patterns
        let usesQuestions = contents.contains { $0.contains("?") }
        let usesFirstPerson = contents.contains { entry in
            ["I ", "I'm", "I've", "My ", "me "].contains { entry.contains($0) }
        }
        
        var styleGuidance = ""
        
        if averageLength < 50 {
            styleGuidance += "Write in a concise, focused style with shorter entries. "
        } else if averageLength > 200 {
            styleGuidance += "Write in a detailed, expansive style with rich descriptions. "
        } else {
            styleGuidance += "Write in a moderate, thoughtful style. "
        }
        
        if emotionalContent {
            styleGuidance += "Include emotional reflection and feelings. "
        }
        
        if usesQuestions {
            styleGuidance += "Use reflective questions as part of the writing style. "
        }
        
        if usesFirstPerson {
            styleGuidance += "Write from a personal, first-person perspective. "
        }
        
        return styleGuidance
    }
    
    private func extractRecentContent() -> [String] {
        return recentEntries.map { $0.content }
    }
    
    private func useSuggestedEntry() {
        guard !suggestedEntry.isEmpty else { return }
        
        // Create and save the suggested entry as a new journal entry
        let newEntry = JournalEntry(
            content: suggestedEntry,
            entryType: .aiGenerated,
            realityLevel: 0.7, // Mix of real and creative
            createdDate: Date()
        )
        
        modelContext.insert(newEntry)
        
        do {
            try modelContext.save()
            print("✅ Saved suggested entry as new journal entry")
            
            // Clear the suggestion after successful save
            self.suggestedEntry = ""
        } catch {
            print("❌ Failed to save suggested entry: \(error)")
        }
    }
}

struct SuggestedEntryCardView: View {
    let suggestedEntry: String
    let isGenerating: Bool
    let generationProgress: Double
    let onGenerate: () -> Void
    let onUse: () -> Void
    @ObservedObject var groqGenerator: GroqAIGenerator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Your Suggested Journal Entry")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // AI indicator
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("AI Generated")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
                
                Text("Based on your writing style from recent entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Entry content
            VStack(alignment: .leading, spacing: 12) {
                if isGenerating {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("AI is writing...")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        
                        // Streaming text display
                        ScrollView {
                            Text(groqGenerator.streamingText)
                                .font(.body)
                                .lineSpacing(3)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 140)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .frame(minHeight: 80, alignment: .top)
                } else if suggestedEntry.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "wand.and.stars")
                            .font(.title2)
                            .foregroundColor(.orange.opacity(0.7))
                        
                        Text("Tap 'Generate New' to create an AI-powered journal entry suggestion")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Adjust the sliders below to customize the creative style")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(minHeight: 80, alignment: .center)
                } else {
                    ScrollView {
                        Text(suggestedEntry)
                            .font(.body)
                            .lineSpacing(3)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .padding(16)
                    }
                    .frame(maxHeight: 180)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onGenerate) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                        Text("Generate New")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .disabled(isGenerating)
                
                Spacer()
                
                if !suggestedEntry.isEmpty && !isGenerating {
                    Button(action: onUse) {
                        Text("Use This Entry")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct DailyThemeSuggestionsView: View {
    @Binding var selectedTheme: GroqAIGenerator.ThemePrompts?
    let onThemeChange: () -> Void
    
    // Daily random suggestions based on current date
    private var dailySuggestions: [GroqAIGenerator.ThemePrompts] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        
        // Use day of year as seed for consistent daily suggestions
        var generator = SeededRandomNumberGenerator(seed: UInt64(dayOfYear))
        let allThemes = GroqAIGenerator.ThemePrompts.allCases
        return Array(allThemes.shuffled(using: &generator).prefix(4))
    }
    
    private var themesByCategory: [String: [GroqAIGenerator.ThemePrompts]] {
        Dictionary(grouping: GroqAIGenerator.ThemePrompts.allCases) { $0.category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Suggested Themes")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(selectedTheme?.displayName ?? "Choose a theme to personalize your AI writing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if selectedTheme != nil {
                    Button("Clear") {
                        selectedTheme = nil
                        onThemeChange()
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }
            
            // Daily suggestions
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Daily Picks")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(dailySuggestions, id: \.self) { theme in
                            ThemeCardView(
                                theme: theme,
                                isSelected: selectedTheme == theme,
                                onSelect: {
                                    selectedTheme = theme
                                    onThemeChange()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Grouped themes
            VStack(alignment: .leading, spacing: 12) {
                ForEach(["Motivational", "Inspirational", "Atmospheric"], id: \.self) { category in
                    if let themes = themesByCategory[category] {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(themes, id: \.self) { theme in
                                        ThemeCardView(
                                            theme: theme,
                                            isSelected: selectedTheme == theme,
                                            isCompact: true,
                                            onSelect: {
                                                selectedTheme = theme
                                                onThemeChange()
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

struct ThemeCardView: View {
    let theme: GroqAIGenerator.ThemePrompts
    let isSelected: Bool
    var isCompact: Bool = false
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: isCompact ? 4 : 6) {
                Text(theme.emoji)
                    .font(isCompact ? .body : .title2)
                Text(theme.displayName)
                    .font(isCompact ? .caption2 : .caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, isCompact ? 8 : 12)
            .padding(.vertical, isCompact ? 6 : 10)
            .frame(width: isCompact ? 70 : 85, height: isCompact ? 55 : 70)
            .background(
                isSelected ? 
                    Color.orange.opacity(0.15) :
                    Color.gray.opacity(0.08)
            )
            .foregroundColor(
                isSelected ? 
                    .orange : 
                    .primary
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? 
                            Color.orange.opacity(0.8) : 
                            Color.clear, 
                        lineWidth: 2
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// Seeded random number generator for consistent daily suggestions
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1664525 &+ 1013904223
        return state
    }
}

#Preview {
    HomeView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}