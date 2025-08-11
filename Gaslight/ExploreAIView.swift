//
//  ExploreAIView.swift
//  Gaslight
//
//  Created by Albert Xu on 8/11/25.
//

import SwiftUI
import SwiftData

struct ExploreAIView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [JournalEntry]
    
    // Mock AI features for exploration
    private let aiFeatures = [
        AIFeature(
            title: "Dream Journal Generator",
            description: "Transform your fragmented dream memories into vivid, coherent narratives with our specialized dream interpretation AI.",
            icon: "moon.zzz.fill",
            backgroundColor: .purple,
            category: "Creative Writing"
        ),
        AIFeature(
            title: "Mood Pattern Analysis",
            description: "Discover hidden emotional patterns in your entries and get personalized insights about your mental wellness journey.",
            icon: "chart.line.uptrend.xyaxis",
            backgroundColor: .blue,
            category: "Analytics"
        ),
        AIFeature(
            title: "Future Self Letters",
            description: "Let AI help you write meaningful letters to your future self, based on your current goals and aspirations.",
            icon: "envelope.badge.person.crop",
            backgroundColor: .green,
            category: "Reflection"
        ),
        AIFeature(
            title: "Memory Weaver",
            description: "Connect scattered memories and experiences into beautiful, cohesive life stories using advanced AI storytelling.",
            icon: "brain.head.profile",
            backgroundColor: .orange,
            category: "Storytelling"
        ),
        AIFeature(
            title: "Gratitude Amplifier",
            description: "Transform simple moments into profound gratitude entries that help you appreciate life's subtle beauties.",
            icon: "heart.circle.fill",
            backgroundColor: .pink,
            category: "Mindfulness"
        ),
        AIFeature(
            title: "Creative Prompt Studio",
            description: "Generate unlimited, personalized writing prompts that evolve with your interests and writing style.",
            icon: "lightbulb.max.fill",
            backgroundColor: .yellow,
            category: "Inspiration"
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Explore AI")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Discover powerful AI writing tools")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // AI brain icon
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 32))
                                .foregroundColor(.orange)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.orange.opacity(0.1))
                                )
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Stats row
                        HStack(spacing: 20) {
                            StatCardView(title: "AI Features", value: "\(aiFeatures.count)", color: .orange)
                            StatCardView(title: "Your Entries", value: "\(entries.count)", color: .blue)
                            StatCardView(title: "Coming Soon", value: "∞", color: .purple)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Categories section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("AI Writing Tools")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            Spacer()
                        }
                        
                        // Feature cards
                        ForEach(aiFeatures, id: \.title) { feature in
                            AIFeatureCardView(feature: feature)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Bottom spacing for floating button
                    Spacer()
                        .frame(height: 120)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct AIFeature {
    let title: String
    let description: String
    let icon: String
    let backgroundColor: Color
    let category: String
}

struct StatCardView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct AIFeatureCardView: View {
    let feature: AIFeature
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon section
            VStack {
                Image(systemName: feature.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        feature.backgroundColor,
                                        feature.backgroundColor.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: feature.backgroundColor.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            // Content section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(feature.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(feature.backgroundColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(feature.backgroundColor.opacity(0.1))
                        )
                    
                    Spacer()
                }
                
                Text(feature.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        // TODO: Implement feature exploration
                    }) {
                        HStack(spacing: 4) {
                            Text("Explore")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                                .font(.caption)
                        }
                        .foregroundColor(feature.backgroundColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(feature.backgroundColor, lineWidth: 1)
                        )
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    ExploreAIView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}