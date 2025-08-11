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
    @Query private var entries: [JournalEntry]
    
    // Mock AI suggestions for now
    private let suggestions = [
        AISuggestion(
            title: "Reflect on Your Morning Routine",
            description: "Based on your recent entries about productivity, explore how your morning sets the tone for your entire day.",
            imageName: "sunrise.fill",
            backgroundColor: .orange
        ),
        AISuggestion(
            title: "Weekend Adventure Memories",
            description: "You've mentioned wanting more excitement. Write about a perfect weekend adventure you'd love to experience.",
            imageName: "mountain.2.fill",
            backgroundColor: .green
        ),
        AISuggestion(
            title: "Coffee Shop Conversations",
            description: "Your entries show you enjoy social connections. Imagine an interesting conversation with a stranger at your favorite café.",
            imageName: "cup.and.saucer.fill",
            backgroundColor: .brown
        ),
        AISuggestion(
            title: "Late Night Thoughts",
            description: "Explore those deep thoughts that come to you when the world is quiet and your mind starts wandering.",
            imageName: "moon.stars.fill",
            backgroundColor: .indigo
        ),
        AISuggestion(
            title: "Creative Breakthrough",
            description: "Based on your work patterns, write about a moment when everything clicks and creativity flows freely.",
            imageName: "lightbulb.fill",
            backgroundColor: .yellow
        )
    ]
    
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
                                Text("\(entries.count)")
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
                        
                        Text("AI-Powered Writing Suggestions")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    
                    // Suggestion cards
                    ForEach(suggestions, id: \.title) { suggestion in
                        SuggestionCardView(suggestion: suggestion)
                            .padding(.horizontal)
                    }
                    
                    // Bottom spacing for floating button
                    Spacer()
                        .frame(height: 100)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct AISuggestion {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

struct SuggestionCardView: View {
    let suggestion: AISuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // AI-generated image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                suggestion.backgroundColor.opacity(0.8),
                                suggestion.backgroundColor.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                
                VStack {
                    Image(systemName: suggestion.imageName)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Text("AI Generated")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            // Content section
            VStack(alignment: .leading, spacing: 12) {
                Text(suggestion.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(suggestion.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                HStack {
                    // AI indicator
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("AI Suggestion")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                    
                    Spacer()
                    
                    // Action button
                    Button(action: {
                        // TODO: Implement suggestion selection
                    }) {
                        Text("Start Writing")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(16)
        }
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