//
//  ThemeSlidersView.swift
//  Gaslight
//
//  Created by Claude on 8/12/25.
//

import SwiftUI

struct ThemeSlidersView: View {
    @ObservedObject var groqGenerator: GroqAIGenerator
    let onSliderChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Theme Controls")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Adjust the creative dimensions of your AI-generated entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Reality Level Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Reality Level")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(realityLevelText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Fantastical")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                        .frame(width: 60, alignment: .leading)
                    
                    ZStack(alignment: .leading) {
                        // Gradient background track
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 6)
                        
                        // Custom slider implementation with drag gesture
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Custom rectangular thumb
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 24, height: 16)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                    .offset(x: CGFloat(groqGenerator.realityLevel) * (geometry.size.width - 24))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newValue = min(max(0, value.location.x / geometry.size.width), 1)
                                                let steppedValue = round(newValue * 10) / 10
                                                groqGenerator.realityLevel = steppedValue
                                                addHapticFeedback()
                                            }
                                            .onEnded { _ in
                                                onSliderChange()
                                            }
                                    )
                            }
                        }
                        .frame(height: 20)
                        .contentShape(Rectangle())
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    // Handle tap on track - will be handled by DragGesture instead
                                }
                        )
                    }
                    
                    Text("Real")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(width: 50, alignment: .trailing)
                }
            }
            
            // Emotional Level Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Emotional Tone")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(emotionalLevelText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Emotional")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.pink)
                        .frame(width: 60, alignment: .leading)
                    
                    ZStack(alignment: .leading) {
                        // Gradient background track
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.pink, .green]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 6)
                        
                        // Custom slider implementation with drag gesture
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Custom rectangular thumb
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 24, height: 16)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                    .offset(x: CGFloat(groqGenerator.emotionalLevel) * (geometry.size.width - 24))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newValue = min(max(0, value.location.x / geometry.size.width), 1)
                                                let steppedValue = round(newValue * 10) / 10
                                                groqGenerator.emotionalLevel = steppedValue
                                                addHapticFeedback()
                                            }
                                            .onEnded { _ in
                                                onSliderChange()
                                            }
                                    )
                            }
                        }
                        .frame(height: 20)
                        .contentShape(Rectangle())
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    // Handle tap on track - will be handled by DragGesture instead
                                }
                        )
                    }
                    
                    Text("Inspired")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .frame(width: 50, alignment: .trailing)
                }
            }
            
            // Tone Level Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Energy Level")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(toneLevelText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Peaceful")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.cyan)
                        .frame(width: 60, alignment: .leading)
                    
                    ZStack(alignment: .leading) {
                        // Gradient background track
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.cyan, .red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 6)
                        
                        // Custom slider implementation with drag gesture
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Custom rectangular thumb
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 24, height: 16)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                    .offset(x: CGFloat(groqGenerator.toneLevel) * (geometry.size.width - 24))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newValue = min(max(0, value.location.x / geometry.size.width), 1)
                                                let steppedValue = round(newValue * 10) / 10
                                                groqGenerator.toneLevel = steppedValue
                                                addHapticFeedback()
                                            }
                                            .onEnded { _ in
                                                onSliderChange()
                                            }
                                    )
                            }
                        }
                        .frame(height: 20)
                        .contentShape(Rectangle())
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    // Handle tap on track - will be handled by DragGesture instead
                                }
                        )
                    }
                    
                    Text("Energetic")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .frame(width: 50, alignment: .trailing)
                }
            }
            
            // Reset button
            HStack {
                Spacer()
                Button("Reset to Balanced") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        groqGenerator.realityLevel = 0.5
                        groqGenerator.emotionalLevel = 0.5
                        groqGenerator.toneLevel = 0.5
                    }
                    onSliderChange()
                }
                .font(.caption)
                .foregroundColor(.blue)
                .opacity(isAtDefaults ? 0.5 : 1.0)
                .disabled(isAtDefaults)
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
    
    private var realityLevelText: String {
        let percentage = Int(groqGenerator.realityLevel * 100)
        let superlatives = generateRealitySuperlatives(for: groqGenerator.realityLevel)
        return "\(percentage)% - \(superlatives)"
    }
    
    private var emotionalLevelText: String {
        let percentage = Int(groqGenerator.emotionalLevel * 100)
        let superlatives = generateEmotionalSuperlatives(for: groqGenerator.emotionalLevel)
        return "\(percentage)% - \(superlatives)"
    }
    
    private var toneLevelText: String {
        let percentage = Int(groqGenerator.toneLevel * 100)
        let superlatives = generateToneSuperlatives(for: groqGenerator.toneLevel)
        return "\(percentage)% - \(superlatives)"
    }
    
    private var isAtDefaults: Bool {
        abs(groqGenerator.realityLevel - 0.5) < 0.1 &&
        abs(groqGenerator.emotionalLevel - 0.5) < 0.1 &&
        abs(groqGenerator.toneLevel - 0.5) < 0.1
    }
    
    private func addHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    // MARK: - Superlative Generation
    
    private func generateRealitySuperlatives(for level: Double) -> String {
        let realityDescriptors: [[String]] = [
            // Fantastical (0.0-0.2)
            ["Wildly Imaginative", "Purely Fantastical", "Magically Surreal", "Dreamlike", "Otherworldly"],
            // Creative (0.2-0.4)
            ["Artistically Creative", "Imaginatively Rich", "Creatively Bold", "Inventively Unique", "Expressively Free"],
            // Balanced (0.4-0.6)
            ["Thoughtfully Balanced", "Harmoniously Mixed", "Seamlessly Blended", "Perfectly Centered", "Beautifully Nuanced"],
            // Realistic (0.6-0.8)
            ["Genuinely Realistic", "Authentically Grounded", "Truthfully Honest", "Practically Focused", "Realistically Rooted"],
            // Real (0.8-1.0)
            ["Purely Factual", "Absolutely Real", "Completely Authentic", "Utterly Genuine", "Entirely Truthful"]
        ]
        
        let sectionIndex = min(4, Int(level * 5))
        let section = realityDescriptors[sectionIndex]
        
        // Use a consistent seed based on the level to get reproducible results
        let seed = Int(level * 1000) % section.count
        return section[seed]
    }
    
    private func generateEmotionalSuperlatives(for level: Double) -> String {
        let emotionalDescriptors: [[String]] = [
            // Emotional (0.0-0.2)
            ["Deeply Emotional", "Profoundly Moving", "Intensely Personal", "Vulnerably Raw", "Stirringly Heartfelt"],
            // Feeling-focused (0.2-0.4)
            ["Emotionally Rich", "Feelingly Aware", "Sensitively Attuned", "Compassionately Open", "Empathetically Deep"],
            // Balanced (0.4-0.6)
            ["Emotionally Balanced", "Wisely Centered", "Thoughtfully Feeling", "Mindfully Aware", "Gracefully Poised"],
            // Uplifting (0.6-0.8)
            ["Encouragingly Positive", "Uplifting & Hopeful", "Optimistically Bright", "Inspiringly Warm", "Joyfully Elevated"],
            // Inspiring (0.8-1.0)
            ["Deeply Inspiring", "Transcendently Uplifting", "Brilliantly Motivating", "Powerfully Energizing", "Magnificently Moving"]
        ]
        
        let sectionIndex = min(4, Int(level * 5))
        let section = emotionalDescriptors[sectionIndex]
        
        let seed = Int(level * 1000) % section.count
        return section[seed]
    }
    
    private func generateToneSuperlatives(for level: Double) -> String {
        let toneDescriptors: [[String]] = [
            // Peaceful (0.0-0.2)
            ["Serenely Peaceful", "Tranquilly Calm", "Meditatively Quiet", "Blissfully Still", "Harmoniously Gentle"],
            // Calm (0.2-0.4)
            ["Quietly Reflective", "Softly Contemplative", "Gently Flowing", "Peacefully Steady", "Calmly Centered"],
            // Balanced (0.4-0.6)
            ["Naturally Balanced", "Rhythmically Steady", "Fluidly Adaptable", "Dynamically Stable", "Perfectly Modulated"],
            // Active (0.6-0.8)
            ["Actively Engaged", "Dynamically Alive", "Vibrantly Present", "Spiritedly Moving", "Enthusiastically Alive"],
            // Energetic (0.8-1.0)
            ["Powerfully Energetic", "Explosively Dynamic", "Intensely Passionate", "Electrically Charged", "Magnificently Vibrant"]
        ]
        
        let sectionIndex = min(4, Int(level * 5))
        let section = toneDescriptors[sectionIndex]
        
        let seed = Int(level * 1000) % section.count
        return section[seed]
    }
}

#Preview {
    ThemeSlidersView(
        groqGenerator: GroqAIGenerator.shared,
        onSliderChange: {}
    )
    .padding()
}