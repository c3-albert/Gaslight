//
//  AIEntryGenerator.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import Foundation
import UIKit

enum AIGenerationMode {
    case groq
}

@MainActor
class AIEntryGenerator: ObservableObject {
    static let shared = AIEntryGenerator()
    
    @Published var generationMode: AIGenerationMode = .groq
    private let groqGenerator = GroqAIGenerator.shared
    
    private init() {}
    
    // MARK: - Public API
    
    func generateEntry(realityLevel: Double = 0.0) async -> String {
        return await generateGroqEntry(realityLevel: realityLevel)
    }
    
    func enhanceUserEntry(_ originalText: String, realityLevel: Double) async -> String {
        return await enhanceWithGroq(originalText, realityLevel: realityLevel)
    }
    
    func generateContinuation(for existingText: String, realityLevel: Double) async -> String {
        return await generateGroqContinuation(existingText, realityLevel: realityLevel)
    }
    
    // MARK: - Groq AI Generation
    
    func generateCoreMLEntry(realityLevel: Double = 0.0, recentEntries: [String] = []) async -> String {
        // This method is kept for backward compatibility, now uses Groq
        return await generateGroqEntry(realityLevel: realityLevel, recentEntries: recentEntries)
    }
    
    private func generateGroqEntry(realityLevel: Double = 0.0, recentEntries: [String] = []) async -> String {
        do {
            let prompt = recentEntries.isEmpty ? 
                createPromptForRealityLevel(realityLevel) :
                createContextualPrompt(basedOn: recentEntries, realityLevel: realityLevel)
            
            return try await groqGenerator.generateJournalEntry(
                prompt: prompt,
                recentEntries: recentEntries,
                realityLevel: realityLevel
            )
        } catch {
            print("Groq generation failed: \(error)")
            return await fallbackResponse()
        }
    }
    
    private func generateGroqEntry(realityLevel: Double = 0.0) async -> String {
        return await generateGroqEntry(realityLevel: realityLevel, recentEntries: [])
    }
    
    private func enhanceWithGroq(_ originalText: String, realityLevel: Double) async -> String {
        do {
            let prompt = createEnhancementPrompt(originalText: originalText, realityLevel: realityLevel)
            return try await groqGenerator.generateJournalEntry(
                prompt: prompt,
                recentEntries: [],
                realityLevel: realityLevel
            )
        } catch {
            print("Groq enhancement failed: \(error)")
            return originalText // Return original if enhancement fails
        }
    }
    
    
    private func generateGroqContinuation(_ existingText: String, realityLevel: Double) async -> String {
        do {
            let prompt = createContinuationPrompt(existingText: existingText, realityLevel: realityLevel)
            return try await groqGenerator.generateJournalEntry(
                prompt: prompt,
                recentEntries: [],
                realityLevel: realityLevel
            )
        } catch {
            print("Groq continuation failed: \(error)")
            return await fallbackResponse()
        }
    }
    
    
    
    // MARK: - Prompt Creation
    
    private func createPromptForRealityLevel(_ realityLevel: Double) -> String {
        let prompt = generateCreativePrompt(realityLevel: realityLevel)
        let context = realityLevelToContext(realityLevel)
        return "\(prompt) \(context) Keep it around 100-150 words and write in first person as if someone is writing in their personal journal."
    }
    
    private func generateCreativePrompt(realityLevel: Double) -> String {
        let promptStarters: [String]
        
        if realityLevel < 0.3 {
            // High creativity prompts
            promptStarters = [
                "Write about a moment when the ordinary world felt slightly different than usual.",
                "Describe a time when your intuition picked up on something your logical mind missed.",
                "Explore an experience where coincidences seemed to carry deeper meaning.",
                "Write about noticing patterns or connections that others might overlook.",
                "Describe a moment when your surroundings seemed to respond to your inner state.",
                "Write about a time when an everyday object or situation triggered unexpected insights.",
                "Explore how a routine activity revealed something new about yourself or life.",
                "Describe an experience where reality felt more layered or textured than usual.",
                "Write about a moment when your perception shifted and familiar things felt fresh.",
                "Explore a time when your imagination influenced how you experienced reality."
            ]
        } else if realityLevel < 0.7 {
            // Balanced creativity prompts
            promptStarters = [
                "Write about a recent experience that made you think differently about something.",
                "Describe a conversation or interaction that stayed with you longer than expected.",
                "Explore how a change in your routine affected your mood or perspective.",
                "Write about noticing something new in a familiar environment.",
                "Describe a moment when you felt particularly present or aware.",
                "Write about how weather, lighting, or atmosphere influenced your day.",
                "Explore a time when your expectations didn't match reality.",
                "Describe an experience that challenged or confirmed something you believe.",
                "Write about a moment of clarity or understanding that emerged gradually.",
                "Explore how a creative activity or hobby affected your overall wellbeing."
            ]
        } else {
            // Realistic, grounded prompts
            promptStarters = [
                "Write about the practical challenges and small victories of your recent days.",
                "Describe how you've been managing stress, relationships, or responsibilities.",
                "Explore what you've learned about yourself through recent interactions.",
                "Write about the rhythms and routines that are working or not working for you.",
                "Describe how you've been balancing different priorities and commitments.",
                "Write about the people who have influenced your thinking or mood lately.",
                "Explore how your energy levels and motivation have been fluctuating.",
                "Describe the moments of satisfaction or frustration in your daily life.",
                "Write about the progress you're making toward personal or professional goals.",
                "Explore how your living situation, work, or relationships are evolving."
            ]
        }
        
        return promptStarters.randomElement() ?? "Write a personal journal entry about your recent experiences."
    }
    
    func createContextualPrompt(basedOn recentEntries: [String], realityLevel: Double) -> String {
        guard !recentEntries.isEmpty else {
            return createPromptForRealityLevel(realityLevel)
        }
        
        let contextualFramework = selectContextualFramework()
        let styleContext = analyzeWritingStyle(from: recentEntries)
        let thematicContext = extractCommonThemes(from: recentEntries)
        let contextualGuidance = realityLevelToContext(realityLevel)
        let creativeTwist = generateCreativeTwist(realityLevel: realityLevel)
        
        return """
        \(contextualFramework)
        
        Writing style to match: \(styleContext)
        Common themes in recent entries: \(thematicContext)
        Content guidance: \(contextualGuidance)
        Creative approach: \(creativeTwist)
        
        Write 100-150 words in first person, maintaining the authentic voice and casual tone shown in the examples.
        """
    }
    
    private func selectContextualFramework() -> String {
        let frameworks = [
            "Write a journal entry that builds on the emotional and thematic patterns of recent entries while exploring new dimensions.",
            "Create a journal entry that resonates with recent writing while introducing fresh perspectives and insights.",
            "Develop a journal entry that feels like a natural continuation of the recent writing journey.",
            "Write an entry that honors the established voice while pushing into unexplored emotional or experiential territory.",
            "Create a journal entry that weaves together familiar themes with surprising new connections.",
            "Develop an entry that feels both consistent with recent patterns and refreshingly original."
        ]
        
        return frameworks.randomElement() ?? frameworks[0]
    }
    
    private func generateCreativeTwist(realityLevel: Double) -> String {
        let twists: [String]
        
        if realityLevel < 0.3 {
            twists = [
                "Consider how mundane experiences might contain hidden symbolic meaning.",
                "Explore the possibility that ordinary moments reveal extraordinary truths.",
                "Look for the magical realism embedded in everyday life.",
                "Find the poetry hidden within practical experiences.",
                "Discover the mythic dimensions of personal experience."
            ]
        } else if realityLevel < 0.7 {
            twists = [
                "Find unexpected connections between different areas of life.",
                "Explore how small changes ripple into larger transformations.",
                "Look for the personal growth embedded in routine experiences.",
                "Discover the deeper patterns that emerge from daily life.",
                "Find fresh perspectives on familiar situations."
            ]
        } else {
            twists = [
                "Focus on the honest complexity of real human experience.",
                "Explore the genuine lessons embedded in practical challenges.",
                "Look for authentic moments of insight within ordinary days.",
                "Discover the real wisdom that emerges from lived experience.",
                "Find the meaningful within the genuinely mundane."
            ]
        }
        
        return twists.randomElement() ?? twists[0]
    }
    
    private func createEnhancementPrompt(originalText: String, realityLevel: Double) -> String {
        let enhancementApproach = selectEnhancementApproach(realityLevel: realityLevel)
        let style = realityLevelToStyle(realityLevel)
        return "\(enhancementApproach) \(style) Original text: \(originalText)"
    }
    
    private func selectEnhancementApproach(realityLevel: Double) -> String {
        let approaches: [String]
        
        if realityLevel < 0.3 {
            approaches = [
                "Transform this journal entry by adding layers of meaning and creative insights while preserving its core truth.",
                "Enhance this entry by weaving in metaphorical language and deeper emotional resonance.",
                "Expand this journal entry with imaginative details and unexpected connections.",
                "Elevate this entry by adding poetic elements and symbolic depth.",
                "Enrich this writing with creative perspectives while maintaining its authentic foundation."
            ]
        } else if realityLevel < 0.7 {
            approaches = [
                "Improve this journal entry by adding thoughtful reflection and emotional depth.",
                "Enhance this entry with better flow, clearer insights, and more vivid details.",
                "Refine this writing by strengthening its emotional core and adding meaningful observations.",
                "Develop this entry with richer context and more nuanced self-reflection.",
                "Expand this journal entry with deeper analysis while keeping its conversational tone."
            ]
        } else {
            approaches = [
                "Polish this journal entry by improving clarity, flow, and emotional honesty.",
                "Edit this entry to be more articulate while maintaining its genuine, personal voice.",
                "Enhance this writing by fixing any issues and making the thoughts more coherent.",
                "Refine this entry by strengthening its structure and emotional authenticity.",
                "Improve this journal entry's readability while preserving its honest, everyday tone."
            ]
        }
        
        return approaches.randomElement() ?? approaches[0]
    }
    
    private func createContinuationPrompt(existingText: String, realityLevel: Double) -> String {
        let continuationStyle = selectContinuationStyle(realityLevel: realityLevel)
        let style = realityLevelToStyle(realityLevel)
        return "\(continuationStyle) \(style) Existing text: \(existingText)"
    }
    
    private func selectContinuationStyle(realityLevel: Double) -> String {
        let styles: [String]
        
        if realityLevel < 0.3 {
            styles = [
                "Continue this journal entry by exploring the deeper implications and hidden connections of what's already written.",
                "Extend this entry by following the emotional thread into more imaginative territory.",
                "Continue writing by adding layers of meaning and creative insight to the established narrative.",
                "Develop this entry further by weaving in metaphorical elements and unexpected perspectives.",
                "Expand this journal entry by exploring the symbolic dimensions of the experiences described."
            ]
        } else if realityLevel < 0.7 {
            styles = [
                "Continue this journal entry by developing the thoughts and feelings already expressed.",
                "Extend this entry with additional reflection and personal insight.",
                "Continue writing by exploring the implications and lessons of what's been shared.",
                "Develop this entry further by adding more context and emotional depth.",
                "Expand this journal entry with related experiences and deeper self-understanding."
            ]
        } else {
            styles = [
                "Continue this journal entry by adding practical details and realistic next steps.",
                "Extend this entry with concrete observations and straightforward reflection.",
                "Continue writing by exploring the real-world impacts and lessons learned.",
                "Develop this entry further by adding authentic details and honest assessment.",
                "Expand this journal entry with genuine next thoughts and practical considerations."
            ]
        }
        
        return styles.randomElement() ?? styles[0]
    }
    
    // MARK: - Style Analysis
    
    private func analyzeWritingStyle(from entries: [String]) -> String {
        let sampleText = entries.prefix(5).joined(separator: " ")
        
        // Analyze various style elements
        let avgSentenceLength = calculateAverageSentenceLength(sampleText)
        let casualnessLevel = detectCasualness(sampleText)
        let punctuationStyle = analyzePunctuation(sampleText)
        let vocabularyLevel = analyzeVocabulary(sampleText)
        
        var styleDescription = "The writing style is "
        
        // Sentence length characterization
        if avgSentenceLength < 10 {
            styleDescription += "concise and direct, "
        } else if avgSentenceLength > 20 {
            styleDescription += "flowing with longer, more complex sentences, "
        } else {
            styleDescription += "balanced with moderate sentence length, "
        }
        
        // Casualness level
        if casualnessLevel > 0.6 {
            styleDescription += "very casual and conversational, "
        } else if casualnessLevel > 0.3 {
            styleDescription += "casually approachable, "
        } else {
            styleDescription += "more formal and structured, "
        }
        
        // Vocabulary assessment
        if vocabularyLevel > 0.7 {
            styleDescription += "with sophisticated vocabulary and thoughtful expression."
        } else if vocabularyLevel > 0.4 {
            styleDescription += "with clear, accessible language."
        } else {
            styleDescription += "with simple, everyday language."
        }
        
        return styleDescription
    }
    
    private func extractCommonThemes(from entries: [String]) -> String {
        let combinedText = entries.joined(separator: " ").lowercased()
        
        let themeKeywords = [
            "work": ["work", "job", "boss", "colleague", "meeting", "deadline", "office"],
            "relationships": ["friend", "family", "mom", "dad", "sister", "brother", "relationship", "date"],
            "daily life": ["morning", "coffee", "home", "sleep", "tired", "busy", "routine"],
            "emotions": ["happy", "sad", "stressed", "excited", "worried", "frustrated", "calm"],
            "activities": ["walked", "went", "did", "watched", "read", "cooked", "traveled"],
            "reflection": ["thinking", "realized", "learned", "understand", "remember", "feel", "wonder"]
        ]
        
        var themeScores: [String: Int] = [:]
        
        for (theme, keywords) in themeKeywords {
            let score = keywords.reduce(0) { count, keyword in
                count + combinedText.components(separatedBy: keyword).count - 1
            }
            themeScores[theme] = score
        }
        
        let topThemes = themeScores
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
        
        return topThemes.isEmpty ? "daily experiences and personal reflections" : topThemes.joined(separator: ", ")
    }
    
    private func calculateAverageSentenceLength(_ text: String) -> Double {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard !sentences.isEmpty else { return 10.0 }
        
        let totalWords = sentences.reduce(0) { count, sentence in
            count + sentence.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        }
        
        return Double(totalWords) / Double(sentences.count)
    }
    
    private func detectCasualness(_ text: String) -> Double {
        let casualIndicators = ["like", "kinda", "sorta", "gonna", "wanna", "yeah", "ok", "lol", "tbh", "idk", "omg"]
        let contractions = ["don't", "can't", "won't", "isn't", "aren't", "wasn't", "weren't", "haven't", "hasn't"]
        
        let lowerText = text.lowercased()
        var casualScore = 0
        
        for indicator in casualIndicators + contractions {
            casualScore += lowerText.components(separatedBy: indicator).count - 1
        }
        
        let totalWords = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        return totalWords > 0 ? Double(casualScore) / Double(totalWords) : 0.0
    }
    
    private func analyzePunctuation(_ text: String) -> String {
        let hasEllipses = text.contains("...")
        let hasExclamations = text.contains("!")
        let hasQuestions = text.contains("?")
        
        if hasEllipses && hasExclamations {
            return "expressive punctuation with ellipses and exclamations"
        } else if hasEllipses {
            return "thoughtful pauses with ellipses"
        } else if hasExclamations {
            return "enthusiastic with exclamation marks"
        } else {
            return "standard punctuation"
        }
    }
    
    private func analyzeVocabulary(_ text: String) -> Double {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let uniqueWords = Set(words.map { $0.lowercased() })
        
        guard !words.isEmpty else { return 0.5 }
        
        // Simple vocabulary diversity measure
        let diversity = Double(uniqueWords.count) / Double(words.count)
        
        // Check for sophisticated vocabulary indicators
        let sophisticatedWords = ["however", "therefore", "furthermore", "nonetheless", "consequently", "particularly", "specifically", "essentially"]
        let sophisticatedCount = sophisticatedWords.reduce(0) { count, word in
            count + (text.lowercased().contains(word) ? 1 : 0)
        }
        
        return min(diversity + Double(sophisticatedCount) * 0.1, 1.0)
    }
    
    // MARK: - Reality Level Mapping
    
    private func realityLevelToContext(_ realityLevel: Double) -> String {
        let contexts: [String]
        
        switch realityLevel {
        case 0.0..<0.3:
            contexts = [
                "Focus on imaginative, whimsical, or slightly surreal experiences. Be creative but still personal and relatable.",
                "Explore experiences where reality feels more fluid, symbolic, or meaningful than usual.",
                "Write about moments when the boundaries between inner and outer experience feel permeable.",
                "Focus on the magical realism of everyday life and the poetry hidden in ordinary moments.",
                "Explore experiences where intuition, dreams, and imagination inform understanding."
            ]
        case 0.3..<0.7:
            contexts = [
                "Mix realistic daily experiences with some creative or thoughtful observations. Balance mundane with meaningful.",
                "Weave together concrete experiences with reflective insights and emotional depth.",
                "Balance practical concerns with personal growth and creative perspectives.",
                "Explore the intersection of everyday reality and deeper personal understanding.",
                "Find meaningful patterns within ordinary experiences while staying grounded."
            ]
        default:
            contexts = [
                "Focus on realistic daily experiences, work, relationships, and ordinary life events.",
                "Write about genuine human experiences with honest emotional complexity.",
                "Explore the authentic challenges and satisfactions of real life.",
                "Focus on practical experiences while finding their deeper human significance.",
                "Document life as it actually unfolds, with all its contradictions and growth."
            ]
        }
        
        return contexts.randomElement() ?? contexts[0]
    }
    
    private func realityLevelToStyle(_ realityLevel: Double) -> String {
        let styles: [String]
        
        switch realityLevel {
        case 0.0..<0.3:
            styles = [
                "Allow for creative and imaginative language while keeping it personal.",
                "Use metaphorical thinking and poetic observations that emerge naturally.",
                "Write with the freedom to explore symbolic meaning and creative connections.",
                "Let intuitive language and dreamlike logic inform the expression.",
                "Use creative expression that feels authentic rather than forced."
            ]
        case 0.3..<0.7:
            styles = [
                "Use casual, conversational tone with some creative touches.",
                "Balance everyday language with moments of insight and reflection.",
                "Write conversationally while allowing deeper thoughts to emerge naturally.",
                "Use accessible language that occasionally reaches toward more poetic expression.",
                "Maintain a comfortable tone that can hold both practical and meaningful content."
            ]
        default:
            styles = [
                "Keep it straightforward and realistic, like everyday casual writing.",
                "Use honest, direct language that captures genuine human experience.",
                "Write with the authenticity of someone processing real life.",
                "Use clear, unpretentious language that conveys true emotions and situations.",
                "Maintain the voice of someone reflecting honestly on actual experiences."
            ]
        }
        
        return styles.randomElement() ?? styles[0]
    }
    
    
    // MARK: - Fallback Response
    
    private func fallbackResponse() async -> String {
        let fallbackMessages = [
            "I'm having trouble generating content right now. Please check your API key and internet connection, then try again.",
            "Content generation is temporarily unavailable. Please verify your internet connection and Groq API key in Settings.",
            "Unable to connect to AI services at the moment. Check your network connection and API configuration, then retry.",
            "AI generation failed to complete. Please ensure you have a valid API key and stable internet connection."
        ]
        
        return fallbackMessages.randomElement() ?? fallbackMessages[0]
    }
}