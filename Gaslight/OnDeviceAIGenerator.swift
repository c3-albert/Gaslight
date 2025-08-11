//
//  OnDeviceAIGenerator.swift
//  Gaslight
//
//  Created by Albert Xu on 8/6/25.
//

import Foundation
import NaturalLanguage

@MainActor
class OnDeviceAIGenerator: ObservableObject {
    static let shared = OnDeviceAIGenerator()
    
    private let capabilityDetector = DeviceCapabilityDetector.shared
    @Published var isModelLoaded = false
    @Published var isLoading = false
    @Published var loadingProgress: Double = 0.0
    @Published var currentBackend: AIBackend = .none
    
    // Different AI backends
    private var swiftTransformersGenerator: SwiftTransformersGenerator?
    private var lightweightModelGenerator: LightweightModelGenerator?
    private var enhancedTemplateGenerator: EnhancedTemplateGenerator?
    
    private init() {
        initializeAppropriateBackend()
    }
    
    // MARK: - Initialization
    
    private func initializeAppropriateBackend() {
        let tier = capabilityDetector.aiCapabilityTier
        
        switch tier {
        case .premium:
            currentBackend = .swiftTransformers
            swiftTransformersGenerator = SwiftTransformersGenerator()
        case .standard:
            currentBackend = .lightweightModel
            lightweightModelGenerator = LightweightModelGenerator()
        case .basic:
            currentBackend = .enhancedTemplates
            enhancedTemplateGenerator = EnhancedTemplateGenerator()
            isModelLoaded = true // Templates don't need loading
        }
        
        print("🤖 Initialized AI backend: \(currentBackend) for device tier: \(tier)")
    }
    
    // MARK: - Model Loading
    
    func loadModel() async throws {
        guard !isModelLoaded && !isLoading else { return }
        
        isLoading = true
        loadingProgress = 0.1
        
        defer {
            isLoading = false
        }
        
        do {
            switch currentBackend {
            case .swiftTransformers:
                try await loadSwiftTransformersModel()
            case .lightweightModel:
                try await loadLightweightModel()
            case .enhancedTemplates:
                // Templates don't need loading
                break
            case .none:
                throw OnDeviceAIError.noBackendAvailable
            }
            
            isModelLoaded = true
            loadingProgress = 1.0
            print("✅ On-device AI model loaded successfully with \(currentBackend) backend")
            
        } catch {
            print("❌ Failed to load on-device AI model: \(error)")
            throw error
        }
    }
    
    private func loadSwiftTransformersModel() async throws {
        loadingProgress = 0.3
        
        guard let generator = swiftTransformersGenerator else {
            throw OnDeviceAIError.generatorNotInitialized
        }
        
        loadingProgress = 0.6
        try await generator.loadModel()
        loadingProgress = 0.9
    }
    
    private func loadLightweightModel() async throws {
        loadingProgress = 0.3
        
        guard let generator = lightweightModelGenerator else {
            throw OnDeviceAIError.generatorNotInitialized
        }
        
        loadingProgress = 0.6
        try await generator.loadModel()
        loadingProgress = 0.9
    }
    
    // MARK: - Text Generation
    
    func generateJournalEntry(prompt: String, realityLevel: Double) async throws -> String {
        // Auto-load model if needed
        if !isModelLoaded && currentBackend != .enhancedTemplates {
            try await loadModel()
        }
        
        let context = createJournalContext(prompt: prompt, realityLevel: realityLevel)
        
        switch currentBackend {
        case .swiftTransformers:
            guard let generator = swiftTransformersGenerator else {
                throw OnDeviceAIError.generatorNotInitialized
            }
            return try await generator.generateText(context: context)
            
        case .lightweightModel:
            guard let generator = lightweightModelGenerator else {
                throw OnDeviceAIError.generatorNotInitialized
            }
            return try await generator.generateText(context: context)
            
        case .enhancedTemplates:
            guard let generator = enhancedTemplateGenerator else {
                throw OnDeviceAIError.generatorNotInitialized
            }
            return await generator.generateText(context: context)
            
        case .none:
            throw OnDeviceAIError.noBackendAvailable
        }
    }
    
    func enhanceUserEntry(_ originalText: String, realityLevel: Double) async throws -> String {
        let enhancementPrompt = createEnhancementPrompt(originalText: originalText, realityLevel: realityLevel)
        return try await generateJournalEntry(prompt: enhancementPrompt, realityLevel: realityLevel)
    }
    
    func continueEntry(_ existingText: String, realityLevel: Double) async throws -> String {
        let continuationPrompt = createContinuationPrompt(existingText: existingText, realityLevel: realityLevel)
        return try await generateJournalEntry(prompt: continuationPrompt, realityLevel: realityLevel)
    }
    
    // MARK: - Context Creation
    
    private func createJournalContext(prompt: String, realityLevel: Double) -> GenerationContext {
        let style = determineWritingStyle(realityLevel: realityLevel)
        let tone = determineWritingTone(realityLevel: realityLevel)
        
        return GenerationContext(
            prompt: prompt,
            style: style,
            tone: tone,
            maxLength: 200,
            temperature: Float(0.3 + realityLevel * 0.4), // 0.3-0.7 range
            realityLevel: realityLevel
        )
    }
    
    private func determineWritingStyle(realityLevel: Double) -> WritingStyle {
        switch realityLevel {
        case 0.0..<0.3:
            return .surreal
        case 0.3..<0.7:
            return .creative
        default:
            return .realistic
        }
    }
    
    private func determineWritingTone(realityLevel: Double) -> WritingTone {
        // Mix of casual and thoughtful based on reality level
        let casualWeight = realityLevel
        let thoughtfulWeight = 1.0 - realityLevel
        
        if casualWeight > thoughtfulWeight {
            return .casual
        } else {
            return .reflective
        }
    }
    
    private func createEnhancementPrompt(originalText: String, realityLevel: Double) -> String {
        let style = determineWritingStyle(realityLevel: realityLevel)
        
        switch style {
        case .realistic:
            return "Edit this journal entry to improve grammar and clarity while keeping the exact same meaning and content: \(originalText)"
        case .creative:
            return "Edit this journal entry to improve flow and add subtle creative touches while preserving the original message: \(originalText)"
        case .surreal:
            return "Edit this journal entry to fix any errors and add subtle, whimsical language improvements: \(originalText)"
        }
    }
    
    private func createContinuationPrompt(existingText: String, realityLevel: Double) -> String {
        return "Continue writing this journal entry naturally: \(existingText)"
    }
    
    // MARK: - Status Information
    
    var modelStatus: String {
        if isLoading {
            return "Loading \(currentBackend.description)... (\(Int(loadingProgress * 100))%)"
        } else if isModelLoaded {
            return "\(currentBackend.description) ready"
        } else {
            return "\(currentBackend.description) not loaded"
        }
    }
    
    var backendDescription: String {
        let tier = capabilityDetector.aiCapabilityTier
        let device = capabilityDetector.modelIdentifier
        
        return """
        Backend: \(currentBackend.description)
        Device Tier: \(tier)
        Model: \(device)
        Estimated Speed: \(capabilityDetector.estimatedInferenceTime)
        """
    }
}

// MARK: - Supporting Types

enum AIBackend {
    case swiftTransformers
    case lightweightModel
    case enhancedTemplates
    case none
    
    var description: String {
        switch self {
        case .swiftTransformers: return "Swift Transformers"
        case .lightweightModel: return "Lightweight Model"
        case .enhancedTemplates: return "Enhanced Templates"
        case .none: return "None"
        }
    }
}

enum WritingStyle {
    case realistic
    case creative
    case surreal
}

enum WritingTone {
    case casual
    case reflective
    case philosophical
}

struct GenerationContext {
    let prompt: String
    let style: WritingStyle
    let tone: WritingTone
    let maxLength: Int
    let temperature: Float
    let realityLevel: Double
}

enum OnDeviceAIError: Error, LocalizedError {
    case noBackendAvailable
    case generatorNotInitialized
    case modelLoadingFailed(String)
    case generationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noBackendAvailable:
            return "No AI backend available for this device"
        case .generatorNotInitialized:
            return "AI generator not properly initialized"
        case .modelLoadingFailed(let reason):
            return "Failed to load AI model: \(reason)"
        case .generationFailed(let reason):
            return "Text generation failed: \(reason)"
        }
    }
}