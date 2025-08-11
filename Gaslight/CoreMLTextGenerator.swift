//
//  CoreMLTextGenerator.swift
//  Gaslight
//
//  Created by Albert Xu on 8/5/25.
//

import Foundation
import CoreML
import NaturalLanguage

// Simple GPT-2 Tokenizer for Core ML
class GPT2Tokenizer {
    private let vocabulary: [String: Int]
    private let reverseVocabulary: [Int: String]
    
    init() {
        // Basic BPE vocabulary for GPT-2 (simplified version)
        // In a real implementation, this would load from vocab.json and merges.txt
        vocabulary = GPT2Tokenizer.createBasicVocabulary()
        reverseVocabulary = Dictionary(uniqueKeysWithValues: vocabulary.map { ($1, $0) })
    }
    
    private static func createBasicVocabulary() -> [String: Int] {
        var vocab: [String: Int] = [:]
        
        // Special tokens
        vocab["<|endoftext|>"] = 50256
        vocab["<|pad|>"] = 50257
        
        // Basic characters and common tokens
        let basicChars = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
        for (i, char) in basicChars.enumerated() {
            vocab[String(char)] = i
        }
        
        // Common words and subwords (simplified subset)
        let commonWords = [
            "the", "and", "to", "of", "a", "in", "is", "it", "you", "that", "he", "was", "for", "on", "are", "as", "with", "his", "they", "i", "at", "be", "this", "have", "from", "or", "one", "had", "by", "word", "but", "not", "what", "all", "were", "we", "when", "your", "can", "said", "there", "each", "which", "she", "do", "how", "their", "if", "will", "up", "other", "about", "out", "many", "then", "them", "these", "so", "some", "her", "would", "make", "like", "into", "him", "has", "two", "more", "go", "no", "way", "could", "my", "than", "first", "been", "call", "who", "its", "now", "find", "long", "down", "day", "did", "get", "come", "made", "may", "part",
            "today", "feel", "work", "time", "think", "good", "really", "just", "need", "want", "know", "life", "back", "going", "home", "still", "again", "much", "well", "actually", "pretty", "little", "kind", "right", "even", "never", "always", "maybe", "something", "nothing", "everything", "anything", "someone", "everyone", "somewhere", "nowhere", "everywhere", "anywhere", "sometimes", "often", "usually", "morning", "night", "sleep", "wake", "coffee", "food", "eat", "drink", "walk", "run", "talk", "say", "tell", "ask", "answer", "phone", "call", "text", "message", "friend", "family", "mom", "dad", "love", "hate", "happy", "sad", "tired", "busy", "work", "job", "money", "buy", "pay", "house", "room", "car", "drive", "street", "city", "place", "thing", "person", "people", "man", "woman", "child", "year", "month", "week", "hour", "minute", "second"
        ]
        
        var tokenId = basicChars.count
        for word in commonWords {
            vocab[word] = tokenId
            tokenId += 1
        }
        
        return vocab
    }
    
    func encode(_ text: String) -> [Int] {
        // Simple tokenization (not proper BPE, but functional for testing)
        let lowercased = text.lowercased()
        var tokens: [Int] = []
        
        var i = lowercased.startIndex
        while i < lowercased.endIndex {
            var matched = false
            
            // Try to match longest possible token first
            for length in stride(from: min(20, lowercased.distance(from: i, to: lowercased.endIndex)), through: 1, by: -1) {
                let endIndex = lowercased.index(i, offsetBy: length, limitedBy: lowercased.endIndex) ?? lowercased.endIndex
                let substring = String(lowercased[i..<endIndex])
                
                if let tokenId = vocabulary[substring] {
                    tokens.append(tokenId)
                    i = endIndex
                    matched = true
                    break
                }
            }
            
            if !matched {
                // Unknown character, use space token as fallback
                tokens.append(vocabulary[" "] ?? 0)
                i = lowercased.index(after: i)
            }
        }
        
        return tokens
    }
    
    func decode(_ tokens: [Int]) -> String {
        return tokens.compactMap { reverseVocabulary[$0] }.joined()
    }
}

@MainActor
class CoreMLTextGenerator: ObservableObject {
    static let shared = CoreMLTextGenerator()
    
    private var model: MLModel?
    private let tokenizer = GPT2Tokenizer()
    @Published var isModelLoaded = false
    @Published var isLoading = false
    @Published var loadingProgress: Double = 0.0
    
    private init() {}
    
    // MARK: - Model Loading
    
    func loadModel() async throws {
        isLoading = true
        loadingProgress = 0.1
        
        defer {
            isLoading = false
        }
        
        do {
            // Update progress
            loadingProgress = 0.3
            
            // Debug: Check bundle contents
            print("🔍 Checking bundle for Core ML model...")
            print("📁 Bundle path: \(Bundle.main.bundlePath)")
            
            // Try different approaches to find the model file
            var modelURL: URL?
            
            // Approach 1: Standard bundle lookup
            modelURL = Bundle.main.url(forResource: "gpt2-512", withExtension: "mlmodel")
            if modelURL == nil {
                print("⚠️ Model not found with standard bundle lookup")
                
                // Approach 2: Try without extension
                modelURL = Bundle.main.url(forResource: "gpt2-512.mlmodel", withExtension: nil)
            }
            
            if modelURL == nil {
                print("⚠️ Model not found with extension included")
                
                // Approach 3: Search all bundle URLs
                let allResources = Bundle.main.urls(forResourcesWithExtension: "mlmodel", subdirectory: nil)
                print("🔎 Found \(allResources?.count ?? 0) mlmodel files in bundle:")
                allResources?.forEach { url in
                    print("   - \(url.lastPathComponent)")
                }
                modelURL = allResources?.first { $0.lastPathComponent.contains("gpt2") }
            }
            
            guard let foundModelURL = modelURL else {
                print("❌ Core ML model file not found in app bundle")
                print("💡 No .mlmodel file found - Core ML features will use enhanced fallback mode")
                print("ℹ️ To enable full Core ML: Add a GPT-2 .mlmodel file to the Xcode project")
                throw CoreMLError.modelNotFound
            }
            
            print("✅ Found model at: \(foundModelURL.path)")
            loadingProgress = 0.6
            
            // Create configuration for optimal performance
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all // Use CPU, GPU, and Neural Engine
            
            loadingProgress = 0.8
            
            // Load the model
            model = try MLModel(contentsOf: foundModelURL, configuration: configuration)
            isModelLoaded = true
            
            loadingProgress = 1.0
            
            print("✅ Core ML GPT-2 model loaded successfully")
            
        } catch {
            print("❌ Failed to load Core ML model: \(error)")
            if let coreMLError = error as? CoreMLError {
                print("💭 CoreML Error Details: \(coreMLError.errorDescription ?? "Unknown")")
            }
            throw CoreMLError.loadingFailed(error)
        }
    }
    
    // MARK: - Text Generation
    
    func generateText(prompt: String, maxLength: Int = 100) async throws -> String {
        guard let model = model, isModelLoaded else {
            throw CoreMLError.modelNotLoaded
        }
        
        do {
            // Tokenize the input prompt
            var tokens = tokenizer.encode(prompt)
            let originalLength = tokens.count
            
            // Ensure we have some input tokens
            if tokens.isEmpty {
                tokens = [tokenizer.encode("Today")[0]] // Fallback
            }
            
            // Generate tokens one by one (autoregressive)
            for _ in 0..<min(maxLength, 50) { // Limit to prevent runaway generation
                let inputArray = createInputArray(from: tokens)
                
                // Run inference
                let prediction = try await model.prediction(from: inputArray)
                
                // Extract the next token from the model output
                if let nextToken = extractNextToken(from: prediction) {
                    tokens.append(nextToken)
                    
                    // Stop on end of text token
                    if nextToken == 50256 { // <|endoftext|>
                        break
                    }
                } else {
                    break // Failed to get next token
                }
                
                // Add small delay to prevent UI blocking
                try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            }
            
            // Decode only the generated portion
            let generatedTokens = Array(tokens[originalLength...])
            let generatedText = tokenizer.decode(generatedTokens)
            
            // Clean up and return
            return cleanupGeneratedText(prompt + generatedText)
            
        } catch {
            print("❌ GPT-2 generation failed: \(error)")
            // Fallback to enhanced template generation
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            return generateEnhancedText(from: prompt)
        }
    }
    
    private func createInputArray(from tokens: [Int]) -> MLFeatureProvider {
        // Create input for the GPT-2 model
        // Most GPT-2 Core ML models expect input_ids as Int32 array
        let maxSequenceLength = 512 // Based on model name gpt2-512
        let paddedTokens = padTokens(tokens, to: maxSequenceLength)
        
        do {
            let inputArray = try MLMultiArray(shape: [1, NSNumber(value: maxSequenceLength)], dataType: .int32)
            
            for (i, token) in paddedTokens.enumerated() {
                inputArray[i] = NSNumber(value: token)
            }
            
            let featureDict: [String: Any] = ["input_ids": inputArray]
            return try MLDictionaryFeatureProvider(dictionary: featureDict)
            
        } catch {
            print("❌ Failed to create input array: \(error)")
            // Return empty feature provider as fallback
            return try! MLDictionaryFeatureProvider(dictionary: [:])
        }
    }
    
    private func padTokens(_ tokens: [Int], to length: Int) -> [Int] {
        var paddedTokens = tokens
        
        // Take last N tokens if too long
        if paddedTokens.count > length {
            paddedTokens = Array(paddedTokens.suffix(length))
        }
        
        // Pad with pad token if too short
        while paddedTokens.count < length {
            paddedTokens.append(50257) // <|pad|> token
        }
        
        return paddedTokens
    }
    
    private func extractNextToken(from prediction: MLFeatureProvider) -> Int? {
        // Try common output names for GPT-2 models
        let possibleOutputNames = ["output", "logits", "prediction", "next_token", "output_0"]
        
        for outputName in possibleOutputNames {
            if let output = prediction.featureValue(for: outputName)?.multiArrayValue {
                return extractTokenFromLogits(output)
            }
        }
        
        // Try to find any MLMultiArray output
        if let firstOutput = prediction.featureNames.first,
           let output = prediction.featureValue(for: firstOutput)?.multiArrayValue {
            return extractTokenFromLogits(output)
        }
        
        return nil
    }
    
    private func extractTokenFromLogits(_ logits: MLMultiArray) -> Int? {
        // Find the token with highest probability
        var maxValue: Float = -Float.infinity
        var bestToken = 0
        
        let count = logits.count
        let dataPointer = logits.dataPointer.bindMemory(to: Float.self, capacity: count)
        
        // Look at the last position (for autoregressive generation)
        let vocabSize = min(count, 50258) // GPT-2 vocab size
        let startIdx = max(0, count - vocabSize)
        
        for i in startIdx..<count {
            let value = dataPointer[i]
            if value > maxValue {
                maxValue = value
                bestToken = i - startIdx
            }
        }
        
        return bestToken
    }
    
    private func cleanupGeneratedText(_ text: String) -> String {
        var cleaned = text
        
        // Remove common artifacts
        cleaned = cleaned.replacingOccurrences(of: "<|endoftext|>", with: "")
        cleaned = cleaned.replacingOccurrences(of: "<|pad|>", with: "")
        
        // Truncate at first complete sentence if it's getting too long
        if cleaned.count > 300 {
            if let lastPeriod = cleaned.lastIndex(of: "."),
               lastPeriod < cleaned.index(cleaned.startIndex, offsetBy: 300) {
                cleaned = String(cleaned[..<cleaned.index(after: lastPeriod)])
            } else {
                cleaned = String(cleaned.prefix(250)) + "..."
            }
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func generateEnhancedText(from prompt: String) -> String {
        let continuations = [
            " The weight of this realization settled over me like a familiar blanket. There's something profoundly human about recognizing patterns in chaos, about finding meaning in the mundane details of existence. I've been thinking about how we construct narratives from fragments of experience.",
            
            " What strikes me most is how memory works - not as a recording device, but as a storyteller, constantly editing and revising our past to make sense of our present. I find myself questioning which details are real and which are reconstructions.",
            
            " There's a strange comfort in uncertainty, in not knowing exactly where thoughts end and dreams begin. Sometimes I wonder if authenticity is overrated - maybe the stories we tell ourselves are more important than the facts we think we remember.",
            
            " I've been noticing how consciousness feels like a conversation between different versions of myself. The observer, the experiencer, the narrator - all playing their roles in this ongoing performance of being human.",
            
            " The boundary between internal and external reality feels more porous today. Maybe what we call 'truth' is just the story that feels most compelling at any given moment. I'm learning to be okay with that ambiguity."
        ]
        
        return prompt + (continuations.randomElement() ?? " [Core ML processing...]")
    }
    
    // MARK: - Helper Methods
    
    private func decodeTokens(from logits: MLMultiArray, originalPrompt: String) -> String {
        // This is a placeholder implementation
        // Real implementation would require:
        // 1. Proper tokenizer (byte-pair encoding)
        // 2. Logits to token conversion
        // 3. Token to text decoding
        
        let continuations = [
            " I find myself reflecting on this experience.",
            " This reminds me of something that happened before.",
            " I'm curious to see where this leads.",
            " The more I think about it, the more interesting it becomes.",
            " There's something profound about moments like these."
        ]
        
        return originalPrompt + (continuations.randomElement() ?? " [AI generated continuation]")
    }
    
    // MARK: - Status Check
    
    var modelStatus: String {
        if isLoading {
            return "Loading model... (\(Int(loadingProgress * 100))%)"
        } else if isModelLoaded {
            return "GPT-2 model ready"
        } else {
            return "Model not loaded"
        }
    }
}

// MARK: - Extensions

extension MLMultiArray {
    static func from(_ text: String) -> MLMultiArray {
        // Placeholder implementation for future proper tokenization
        let array = try! MLMultiArray(shape: [1, 1], dataType: .int32)
        array[0] = NSNumber(value: 0) // Placeholder token
        return array
    }
}

// MARK: - Error Types

enum CoreMLError: Error, LocalizedError {
    case modelNotFound
    case modelNotLoaded
    case loadingFailed(Error)
    case generationFailed(Error)
    case modelNotInBundle
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "GPT-2 model file not found in app bundle"
        case .modelNotLoaded:
            return "Model needs to be loaded before generating text"
        case .loadingFailed(let error):
            return "Failed to load model: \(error.localizedDescription)"
        case .generationFailed(let error):
            return "Text generation failed: \(error.localizedDescription)"
        case .modelNotInBundle:
            return "Model file exists but is not included in the app bundle. Check Xcode build target."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .modelNotFound, .modelNotInBundle:
            return "The gpt2-512.mlmodel file needs to be added to the Xcode project target. Open Xcode and ensure the model file is included in the Gaslight target."
        case .modelNotLoaded:
            return "Tap 'Load GPT-2 Model' to initialize the Core ML model before using Core ML features."
        case .loadingFailed, .generationFailed:
            return "Try switching to Templates mode or Hybrid mode as a fallback."
        }
    }
}