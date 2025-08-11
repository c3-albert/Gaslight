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
    @StateObject private var coreMLGenerator = CoreMLTextGenerator.shared
    
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
                        isGenerating: isGeneratingEntry || coreMLGenerator.isGenerating,
                        generationProgress: coreMLGenerator.generationProgress,
                        onGenerate: generateSuggestedEntry,
                        onUse: useSuggestedEntry
                    )
                    .padding(.horizontal)
                    
                    // Bottom spacing for floating button
                    Spacer()
                        .frame(height: 100)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                if suggestedEntry.isEmpty && !recentEntries.isEmpty {
                    generateSuggestedEntry()
                }
            }
        }
    }
    
    private func generateSuggestedEntry() {
        guard !recentEntries.isEmpty else {
            suggestedEntry = "Start writing your first journal entry to see personalized suggestions here!"
            return
        }
        
        isGeneratingEntry = true
        
        Task {
            let generator = AIEntryGenerator.shared
            let recentContent = extractRecentContent()
            
            // Use contextual Core ML generation with user history
            let entry = await generator.generateCoreMLEntry(
                realityLevel: 0.7, // Mix of real and creative
                recentEntries: recentContent
            )
            
            await MainActor.run {
                suggestedEntry = entry
                isGeneratingEntry = false
            }
        }
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
                    VStack(spacing: 12) {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generating your journal entry...")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        
                        // Progress bar
                        VStack(spacing: 4) {
                            HStack {
                                Text("Progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(Int(generationProgress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            ProgressView(value: generationProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                .scaleEffect(x: 1, y: 0.5)
                        }
                    }
                    .frame(minHeight: 80, alignment: .center)
                } else if suggestedEntry.isEmpty {
                    Text("Start writing your first journal entry to see personalized suggestions here!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                        .frame(minHeight: 80, alignment: .center)
                } else {
                    ScrollView {
                        Text(suggestedEntry)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .padding(12)
                    }
                    .frame(maxHeight: 120)
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

#Preview {
    HomeView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}