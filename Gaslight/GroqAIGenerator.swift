//
//  GroqAIGenerator.swift
//  Gaslight
//
//  Created by Claude on 8/12/25.
//

import Foundation
import SwiftUI

// MARK: - Groq API Models
struct GroqRequest: Codable {
    let model: String
    let messages: [GroqMessage]
    let temperature: Double
    let max_tokens: Int
    let top_p: Double?
    let stream: Bool
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature, stream
        case max_tokens = "max_tokens"
        case top_p = "top_p"
    }
}

struct GroqMessage: Codable {
    let role: String
    let content: String
}

struct GroqResponse: Codable {
    let id: String
    let choices: [GroqChoice]
    let usage: GroqUsage?
}

struct GroqChoice: Codable {
    let message: GroqMessage
    let finish_reason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finish_reason = "finish_reason"
    }
}

struct GroqUsage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
    
    enum CodingKeys: String, CodingKey {
        case prompt_tokens = "prompt_tokens"
        case completion_tokens = "completion_tokens"
        case total_tokens = "total_tokens"
    }
}

// MARK: - Groq AI Generator
@MainActor
class GroqAIGenerator: ObservableObject {
    static let shared = GroqAIGenerator()
    
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var streamingText: String = ""
    @Published var apiKey: String = ""
    @Published var selectedModel: GroqModel = .llama3_3_70b
    @Published var selectedTheme: ThemePrompts? = nil
    
    // Theme sliders (0.0 to 1.0)
    @Published var realityLevel: Double = 0.5        // 0.0 = Fantastical, 1.0 = Real
    @Published var emotionalLevel: Double = 0.5      // 0.0 = Emotional, 1.0 = Inspired
    @Published var toneLevel: Double = 0.5           // 0.0 = Peaceful, 1.0 = Energetic
    
    private let baseURL = "https://api.groq.com/openai/v1/chat/completions"
    
    enum GroqModel: String, CaseIterable {
        case llama3_1_8b = "llama-3.1-8b-instant"
        case llama3_3_70b = "llama-3.3-70b-versatile"
        
        var displayName: String {
            switch self {
            case .llama3_1_8b: return "Llama 3.1 8B (Fastest)"
            case .llama3_3_70b: return "Llama 3.3 70B (Most capable)"
            }
        }
        
        var maxTokens: Int {
            switch self {
            case .llama3_1_8b: return 8192
            case .llama3_3_70b: return 8192
            }
        }
    }
    
    enum ThemePrompts: String, CaseIterable {
        // Motivational Themes
        case growthMindset = "growth_mindset"
        case gratitude = "gratitude"
        case goalSetting = "goal_setting"
        case confidenceBuilding = "confidence_building"
        
        // Inspirational Themes
        case wisdomInsight = "wisdom_insight"
        case creativeExpression = "creative_expression"
        case adventureDiscovery = "adventure_discovery"
        case connectionLove = "connection_love"
        
        // Moody/Atmospheric Themes
        case contemplative = "contemplative"
        case nostalgic = "nostalgic"
        case melancholicBeauty = "melancholic_beauty"
        case peacefulMindfulness = "peaceful_mindfulness"
        
        var displayName: String {
            switch self {
            case .growthMindset: return "Growth Mindset"
            case .gratitude: return "Gratitude & Appreciation"
            case .goalSetting: return "Goal Setting"
            case .confidenceBuilding: return "Confidence Building"
            case .wisdomInsight: return "Wisdom & Insight"
            case .creativeExpression: return "Creative Expression"
            case .adventureDiscovery: return "Adventure & Discovery"
            case .connectionLove: return "Connection & Love"
            case .contemplative: return "Contemplative"
            case .nostalgic: return "Nostalgic"
            case .melancholicBeauty: return "Melancholic Beauty"
            case .peacefulMindfulness: return "Peaceful Mindfulness"
            }
        }
        
        var emoji: String {
            switch self {
            case .growthMindset: return "🌱"
            case .gratitude: return "🙏"
            case .goalSetting: return "🎯"
            case .confidenceBuilding: return "💪"
            case .wisdomInsight: return "💭"
            case .creativeExpression: return "🎨"
            case .adventureDiscovery: return "🌟"
            case .connectionLove: return "💝"
            case .contemplative: return "🧘"
            case .nostalgic: return "📷"
            case .melancholicBeauty: return "🌙"
            case .peacefulMindfulness: return "🕊️"
            }
        }
        
        var category: String {
            switch self {
            case .growthMindset, .gratitude, .goalSetting, .confidenceBuilding:
                return "Motivational"
            case .wisdomInsight, .creativeExpression, .adventureDiscovery, .connectionLove:
                return "Inspirational"
            case .contemplative, .nostalgic, .melancholicBeauty, .peacefulMindfulness:
                return "Atmospheric"
            }
        }
    }
    
    private init() {
        loadAPIKey()
    }
    
    // MARK: - API Key Management
    
    private func loadAPIKey() {
        // First, try to migrate from UserDefaults if needed
        KeychainManager.migrateFromUserDefaults()
        
        // Load from Keychain
        if let savedKey = KeychainManager.loadAPIKey() {
            apiKey = savedKey
        }
    }
    
    func saveAPIKey(_ key: String) {
        apiKey = key
        if KeychainManager.saveAPIKey(key) {
            print("✅ API key saved securely to Keychain")
        } else {
            print("❌ Failed to save API key to Keychain")
        }
    }
    
    func deleteAPIKey() {
        apiKey = ""
        if KeychainManager.deleteAPIKey() {
            print("✅ API key deleted from Keychain")
        } else {
            print("❌ Failed to delete API key from Keychain")
        }
    }
    
    // MARK: - Text Generation
    
    func generateJournalEntry(
        prompt: String,
        recentEntries: [String] = [],
        realityLevel: Double = 0.7,
        theme: ThemePrompts? = nil
    ) async throws -> String {
        
        guard !apiKey.isEmpty else {
            throw GroqError.noAPIKey
        }
        
        isGenerating = true
        generationProgress = 0.1
        
        defer {
            isGenerating = false
            generationProgress = 0.0
        }
        
        // Build the system prompt based on recent entries and theme
        let systemPrompt = buildSystemPrompt(recentEntries: recentEntries, realityLevel: realityLevel, theme: theme)
        
        // Create the request
        let temperature = max(0.1, min(1.0, 0.7 + (realityLevel * 0.3))) // Clamp between 0.1-1.0
        
        let request = GroqRequest(
            model: selectedModel.rawValue,
            messages: [
                GroqMessage(role: "system", content: systemPrompt),
                GroqMessage(role: "user", content: prompt)
            ],
            temperature: temperature,
            max_tokens: 500,
            top_p: 1.0,
            stream: false
        )
        
        // Debug logging
        print("🔧 Groq Request:")
        print("   Model: \(selectedModel.rawValue)")
        print("   Temperature: \(temperature)")
        print("   System: \(systemPrompt.prefix(100))...")
        print("   User: \(prompt.prefix(100))...")
        
        // Make the API call
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        generationProgress = 0.3
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        generationProgress = 0.7
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GroqError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw GroqError.invalidAPIKey
        }
        
        if httpResponse.statusCode == 429 {
            throw GroqError.rateLimitExceeded
        }
        
        guard httpResponse.statusCode == 200 else {
            // Log the response body for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Groq Error Response (\(httpResponse.statusCode)): \(responseString)")
            }
            throw GroqError.httpError(httpResponse.statusCode)
        }
        
        let groqResponse = try JSONDecoder().decode(GroqResponse.self, from: data)
        
        generationProgress = 1.0
        
        guard let content = groqResponse.choices.first?.message.content else {
            throw GroqError.noContent
        }
        
        // Log token usage
        if let usage = groqResponse.usage {
            print("📊 Groq API Usage: \(usage.total_tokens) tokens (\(usage.prompt_tokens) prompt, \(usage.completion_tokens) completion)")
        }
        
        return content
    }
    
    // MARK: - Helper Methods
    
    private func buildSystemPrompt(recentEntries: [String], realityLevel: Double, theme: ThemePrompts? = nil) -> String {
        var prompt = "You are helping someone write a personal journal entry. "
        
        // Add theme-specific guidance if theme is selected
        if let theme = theme {
            prompt += generateThemeGuidance(theme: theme, realityLevel: realityLevel) + " "
        } else {
            // Use existing creative variations if no theme selected
            let creativeApproach = selectCreativeApproach(realityLevel: realityLevel)
            let narrativePerspective = selectNarrativePerspective()
            let temporalContext = selectTemporalContext()
            let emotionalFramework = selectEmotionalFramework(realityLevel: realityLevel)
            
            prompt += creativeApproach + " "
            prompt += narrativePerspective + " "
            prompt += temporalContext + " "
            prompt += emotionalFramework + " "
        }
        
        if !recentEntries.isEmpty {
            // Analyze recent entries for style
            let averageLength = recentEntries.map { $0.count }.reduce(0, +) / max(recentEntries.count, 1)
            let hasEmotionalContent = recentEntries.contains { entry in
                ["feel", "felt", "happy", "sad", "anxious", "excited"].contains { entry.lowercased().contains($0) }
            }
            
            prompt += "Based on their recent entries, they write "
            
            if averageLength < 200 {
                prompt += "concise, focused entries. "
            } else if averageLength < 500 {
                prompt += "moderate-length, reflective entries. "
            } else {
                prompt += "detailed, expansive entries. "
            }
            
            if hasEmotionalContent {
                prompt += "They often explore their emotions and feelings. "
            }
            
            // Add sample of recent writing
            if let recentEntry = recentEntries.first {
                let preview = String(recentEntry.prefix(200))
                prompt += "Here's a sample of their recent writing style: '\(preview)...' "
                prompt += "Match this tone and style. "
            }
        }
        
        // Add creative constraints and style guidance
        let styleGuidance = generateStyleGuidance(realityLevel: realityLevel)
        prompt += styleGuidance
        
        prompt += "Write in first person. Don't use quotation marks. Make it feel authentic and personal."
        
        return prompt
    }
    
    // MARK: - Creative Prompt Generation
    
    private func selectCreativeApproach(realityLevel: Double) -> String {
        let approaches: [String]
        
        if realityLevel < 0.3 {
            approaches = [
                "Approach this as if reality has soft edges and unexpected connections emerge naturally.",
                "Write as if the ordinary world occasionally reveals hidden patterns and meanings.",
                "Consider how mundane moments might contain traces of the extraordinary.",
                "Explore the liminal spaces where everyday experience meets the unexplained.",
                "Write with the understanding that perspective can transform any situation."
            ]
        } else if realityLevel < 0.7 {
            approaches = [
                "Balance concrete observations with intuitive insights and personal reflections.",
                "Weave together factual experiences with the emotional truths they reveal.",
                "Find the meaningful patterns within ordinary daily experiences.",
                "Explore how external events reflect internal states and growth.",
                "Consider both the surface reality and the deeper currents beneath."
            ]
        } else {
            approaches = [
                "Focus on authentic human experiences with honest emotional complexity.",
                "Capture the texture of real life with all its contradictions and nuances.",
                "Write about genuine moments that reveal character and growth.",
                "Explore the profound within the ordinary without romanticizing it.",
                "Document life as it actually unfolds, not as it might ideally be."
            ]
        }
        
        return approaches.randomElement() ?? approaches[0]
    }
    
    private func selectNarrativePerspective() -> String {
        let perspectives = [
            "Write from the perspective of someone processing their day with curiosity and self-awareness.",
            "Adopt the voice of someone comfortable with uncertainty and complexity.",
            "Write as someone who finds significance in small details and quiet moments.",
            "Use the perspective of someone learning to understand themselves better.",
            "Write from the viewpoint of someone navigating life with both vulnerability and strength.",
            "Adopt the voice of someone who sees growth opportunities in daily challenges."
        ]
        
        return perspectives.randomElement() ?? perspectives[0]
    }
    
    private func selectTemporalContext() -> String {
        let contexts = [
            "Consider how this moment connects to the broader arc of personal development.",
            "Reflect on how today's experiences build upon or contrast with recent patterns.",
            "Think about the relationship between immediate reactions and longer-term understanding.",
            "Explore how present awareness differs from past perspectives on similar situations.",
            "Consider the interplay between momentary feelings and deeper, evolving insights.",
            "Reflect on how current experiences might be preparing you for future growth."
        ]
        
        return contexts.randomElement() ?? contexts[0]
    }
    
    private func selectEmotionalFramework(realityLevel: Double) -> String {
        let frameworks: [String]
        
        if realityLevel < 0.4 {
            frameworks = [
                "Embrace emotional complexity where feelings can be contradictory and multi-layered.",
                "Allow space for emotions that don't fit neat categories or logical explanations.",
                "Write with acceptance that some feelings exist beyond rational understanding.",
                "Explore the emotional landscape where logic and intuition intersect.",
                "Honor the full spectrum of human feeling without judgment or analysis."
            ]
        } else {
            frameworks = [
                "Write with emotional honesty about both pleasant and difficult feelings.",
                "Explore emotions as information about values, needs, and growth edges.",
                "Consider how feelings connect to actions, choices, and relationships.",
                "Write about emotions as part of the human experience worth understanding.",
                "Reflect on emotional responses as teachers about what matters most."
            ]
        }
        
        return frameworks.randomElement() ?? frameworks[0]
    }
    
    private func generateStyleGuidance(realityLevel: Double) -> String {
        let guidanceElements = [
            generateSensoryGuidance(),
            generateRhythmGuidance(),
            generateImageryGuidance(realityLevel: realityLevel),
            generateToneGuidance(realityLevel: realityLevel)
        ]
        
        // Randomly select 2-3 guidance elements to avoid overwhelming the prompt
        let selectedElements = guidanceElements.shuffled().prefix(Int.random(in: 2...3))
        return selectedElements.joined(separator: " ")
    }
    
    private func generateSensoryGuidance() -> String {
        let sensoryPrompts = [
            "Include specific sensory details that ground the experience in physical reality.",
            "Use concrete images and sensations to make abstract thoughts tangible.",
            "Weave in textures, sounds, or visual details that capture the moment's atmosphere.",
            "Let physical sensations inform and deepen emotional observations.",
            "Use the five senses to create presence and immediacy in the writing."
        ]
        
        return sensoryPrompts.randomElement() ?? sensoryPrompts[0]
    }
    
    private func generateRhythmGuidance() -> String {
        let rhythmPrompts = [
            "Vary sentence length to create natural flow and emphasis.",
            "Use pauses and breaks that mirror the natural rhythm of thought.",
            "Let the writing pace match the emotional tempo of the experience.",
            "Create breathing room between ideas with strategic white space.",
            "Use repetition and variation to build meaning through pattern."
        ]
        
        return rhythmPrompts.randomElement() ?? rhythmPrompts[0]
    }
    
    private func generateImageryGuidance(realityLevel: Double) -> String {
        if realityLevel < 0.4 {
            let imageryPrompts = [
                "Use metaphors that bridge the gap between inner experience and outer reality.",
                "Draw connections between seemingly unrelated elements to reveal hidden patterns.",
                "Let symbolic imagery emerge naturally from the literal details.",
                "Use analogies that illuminate rather than obscure the core experience.",
                "Weave poetic language into practical observations."
            ]
            return imageryPrompts.randomElement() ?? imageryPrompts[0]
        } else {
            let imageryPrompts = [
                "Use clear, vivid descriptions that help readers see and feel the moment.",
                "Choose specific details that reveal character and situation.",
                "Let natural comparisons emerge from genuine observation.",
                "Use imagery that serves the story rather than decorating it.",
                "Ground abstract concepts in concrete, relatable examples."
            ]
            return imageryPrompts.randomElement() ?? imageryPrompts[0]
        }
    }
    
    private func generateToneGuidance(realityLevel: Double) -> String {
        let baseTones = [
            "Maintain a tone of gentle curiosity about life's complexities.",
            "Write with the warmth of someone talking to a trusted friend.",
            "Use a voice that's both vulnerable and resilient.",
            "Adopt a tone of compassionate self-observation.",
            "Write with the honesty of someone committed to growth."
        ]
        
        if realityLevel < 0.3 {
            let creativeTones = [
                "Allow wonder and possibility to color the observations.",
                "Write with openness to mystery and unexpected connections.",
                "Maintain a sense of playful exploration even in serious moments.",
                "Use a tone that welcomes both logic and magic."
            ]
            let combined = baseTones + creativeTones
            return combined.randomElement() ?? baseTones[0]
        } else {
            return baseTones.randomElement() ?? baseTones[0]
        }
    }
    
    // MARK: - Streaming Text Generation
    
    func generateJournalEntryWithStreaming(
        prompt: String,
        recentEntries: [String] = [],
        realityLevel: Double = 0.7,
        theme: ThemePrompts? = nil
    ) async throws -> String {
        
        guard !apiKey.isEmpty else {
            throw GroqError.noAPIKey
        }
        
        isGenerating = true
        streamingText = ""
        
        defer {
            isGenerating = false
        }
        
        // Generate the complete text first (same as before)
        let fullText = try await generateJournalEntry(
            prompt: prompt,
            recentEntries: recentEntries,
            realityLevel: realityLevel,
            theme: theme
        )
        
        // Now simulate streaming by revealing words progressively
        await streamTextWordByWord(fullText)
        
        return fullText
    }
    
    // New slider-based generation method
    func generateJournalEntryWithSliders(
        prompt: String,
        recentEntries: [String] = []
    ) async throws -> String {
        
        guard !apiKey.isEmpty else {
            throw GroqError.noAPIKey
        }
        
        isGenerating = true
        streamingText = ""
        
        defer {
            isGenerating = false
        }
        
        // Build system prompt using slider values
        let systemPrompt = buildSliderBasedPrompt(
            basePrompt: prompt,
            recentEntries: recentEntries,
            reality: realityLevel,
            emotion: emotionalLevel,
            tone: toneLevel
        )
        
        // Generate using existing API call
        let fullText = try await makeAPICall(systemPrompt: systemPrompt, userPrompt: prompt)
        
        // Stream the text word by word
        await streamTextWordByWord(fullText)
        
        return fullText
    }
    
    private func makeAPICall(systemPrompt: String, userPrompt: String) async throws -> String {
        let temperature = 0.8 // Moderate creativity
        
        let request = GroqRequest(
            model: selectedModel.rawValue,
            messages: [
                GroqMessage(role: "system", content: systemPrompt),
                GroqMessage(role: "user", content: userPrompt)
            ],
            temperature: temperature,
            max_tokens: selectedModel.maxTokens,
            top_p: 1.0,
            stream: false
        )
        
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GroqError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GroqError.httpError(httpResponse.statusCode)
        }
        
        let groqResponse = try JSONDecoder().decode(GroqResponse.self, from: data)
        
        guard let content = groqResponse.choices.first?.message.content else {
            throw GroqError.noContent
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func streamTextWordByWord(_ text: String) async {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        streamingText = ""
        
        for (index, word) in words.enumerated() {
            // Add the word to streaming text
            if index == 0 {
                streamingText = word
            } else {
                streamingText += " " + word
            }
            
            // Random delay between 25-75ms for very fast but varied typing
            let delay = Double.random(in: 0.025...0.075)
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
    
    // MARK: - Slider-Based Prompt Generation
    
    private func buildSliderBasedPrompt(
        basePrompt: String,
        recentEntries: [String],
        reality: Double,
        emotion: Double,
        tone: Double
    ) -> String {
        var prompt = "You are helping someone write a personal journal entry. "
        
        // Reality dimension (0.0 = Fantastical, 1.0 = Real)
        if reality < 0.3 {
            prompt += "Write with imaginative, creative, and fantastical elements. "
        } else if reality > 0.7 {
            prompt += "Write with realistic, grounded, and practical observations. "
        } else {
            prompt += "Balance creative imagination with realistic experiences. "
        }
        
        // Emotional dimension (0.0 = Emotional, 1.0 = Inspired)
        if emotion < 0.3 {
            prompt += "Focus on deep emotions, feelings, and personal vulnerability. "
        } else if emotion > 0.7 {
            prompt += "Write with inspiration, motivation, and uplifting perspectives. "
        } else {
            prompt += "Balance emotional depth with inspiring insights. "
        }
        
        // Tone dimension (0.0 = Peaceful, 1.0 = Energetic)
        if tone < 0.3 {
            prompt += "Use a calm, peaceful, and contemplative tone. "
        } else if tone > 0.7 {
            prompt += "Write with energy, passion, and dynamic expression. "
        } else {
            prompt += "Balance peaceful reflection with energetic expression. "
        }
        
        // Add style guidance based on recent entries if available
        if !recentEntries.isEmpty {
            let styleAnalysis = analyzeWritingStyleFromEntries(recentEntries)
            prompt += styleAnalysis
        }
        
        prompt += "Write authentically and make it feel personal and genuine."
        
        return prompt
    }
    
    private func analyzeWritingStyleFromEntries(_ entries: [String]) -> String {
        let totalWords = entries.joined().split(separator: " ").count
        let averageLength = totalWords / max(entries.count, 1)
        
        if averageLength < 50 {
            return "Write in a concise, focused style with shorter entries. "
        } else if averageLength > 200 {
            return "Write in a detailed, expansive style with rich descriptions. "
        } else {
            return "Write in a moderate, thoughtful style. "
        }
    }
    
    // MARK: - Theme-Specific Prompt Generation
    
    private func generateThemeGuidance(theme: ThemePrompts, realityLevel: Double) -> String {
        let baseGuidance = getThemeBaseGuidance(theme: theme)
        let styleGuidance = getThemeStyleGuidance(theme: theme, realityLevel: realityLevel)
        let focusGuidance = getThemeFocusGuidance(theme: theme)
        
        return "\(baseGuidance) \(styleGuidance) \(focusGuidance)"
    }
    
    private func getThemeBaseGuidance(theme: ThemePrompts) -> String {
        switch theme {
        case .growthMindset:
            return "Focus on learning opportunities, challenges as growth experiences, and the journey of self-improvement."
        case .gratitude:
            return "Emphasize appreciation, positive moments, and things worth being thankful for in daily life."
        case .goalSetting:
            return "Write with forward momentum, focusing on aspirations, achievements, and purposeful action."
        case .confidenceBuilding:
            return "Highlight personal strengths, successful moments, and evidence of capability and resilience."
        case .wisdomInsight:
            return "Explore deeper meanings, philosophical reflections, and insights gained from experience."
        case .creativeExpression:
            return "Embrace imagination, artistic thinking, and unique perspectives on ordinary experiences."
        case .adventureDiscovery:
            return "Approach life with curiosity, emphasizing exploration, new experiences, and discovery."
        case .connectionLove:
            return "Focus on relationships, human connection, compassion, and the bonds that matter most."
        case .contemplative:
            return "Write with quiet reflection, deep thought, and mindful observation of inner experiences."
        case .nostalgic:
            return "Draw on memories, past experiences, and the bittersweet beauty of time's passage."
        case .melancholicBeauty:
            return "Find beauty in complex emotions, embracing both light and shadow in human experience."
        case .peacefulMindfulness:
            return "Emphasize present-moment awareness, inner calm, and the beauty of simply being."
        }
    }
    
    private func getThemeStyleGuidance(theme: ThemePrompts, realityLevel: Double) -> String {
        let isCreative = realityLevel < 0.5
        
        switch theme.category {
        case "Motivational":
            return isCreative ? 
                "Use uplifting metaphors and inspiring imagery to convey growth and possibility." :
                "Write with practical optimism, focusing on concrete steps and realistic achievements."
        case "Inspirational":
            return isCreative ?
                "Weave poetic language and transcendent moments into everyday observations." :
                "Find profound meaning in simple, genuine human experiences and connections."
        case "Atmospheric":
            return isCreative ?
                "Create rich, evocative imagery that captures the emotional landscape of the moment." :
                "Use precise, contemplative language that honors the depth of quiet reflection."
        default:
            return "Write authentically from the heart, letting genuine emotion guide the expression."
        }
    }
    
    private func getThemeFocusGuidance(theme: ThemePrompts) -> String {
        switch theme {
        case .growthMindset, .goalSetting:
            return "Consider what you're learning and how you're evolving."
        case .gratitude, .connectionLove:
            return "Notice what brings joy, meaning, and connection to your life."
        case .confidenceBuilding:
            return "Acknowledge your strengths and celebrate your progress."
        case .wisdomInsight, .contemplative:
            return "Dive deep into thoughts and explore what resonates with your inner wisdom."
        case .creativeExpression, .adventureDiscovery:
            return "Let curiosity and imagination guide your observations."
        case .nostalgic:
            return "Explore how past experiences connect to your present understanding."
        case .melancholicBeauty, .peacefulMindfulness:
            return "Embrace the full spectrum of human emotion and find peace within complexity."
        }
    }
    
    // MARK: - Test Connection
    
    func testConnection() async -> Bool {
        guard !apiKey.isEmpty else { return false }
        
        do {
            let _ = try await generateJournalEntry(
                prompt: "Write a single sentence about the weather.",
                realityLevel: 1.0
            )
            return true
        } catch {
            print("❌ Groq connection test failed: \(error)")
            return false
        }
    }
}

// MARK: - Error Types

enum GroqError: LocalizedError {
    case noAPIKey
    case invalidAPIKey
    case rateLimitExceeded
    case invalidResponse
    case noContent
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key configured. Add your Groq API key in Settings."
        case .invalidAPIKey:
            return "Invalid API key. Check your Groq API key in Settings."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please wait a moment and try again."
        case .invalidResponse:
            return "Invalid response from Groq API."
        case .noContent:
            return "No content generated. Please try again."
        case .httpError(let code):
            return "HTTP error \(code). Please try again."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noAPIKey, .invalidAPIKey:
            return "Go to Settings → AI Engine and add your Groq API key from console.groq.com"
        case .rateLimitExceeded:
            return "Groq has generous rate limits (25,000 tokens/min). Wait a few seconds and try again."
        default:
            return "Check your internet connection and try again."
        }
    }
}