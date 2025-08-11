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
        print("🔤 Decoding tokens: \(tokens)")
        
        // Create a more comprehensive GPT-2-style token mapping
        let gpt2TokenMap: [Int: String] = [
            // Common tokens that GPT-2 uses
            0: " ",      // space
            1: "the",
            2: "of", 
            3: "and",
            4: "a",
            5: "to",
            6: "in",
            7: "is",
            8: "you",
            9: "that",
            10: "it",
            11: "he",
            12: "was",
            13: "for",
            14: "on",
            15: "are",
            16: "as",
            17: "I",
            18: "with",
            19: "his",
            20: "they",
            21: "at",
            22: "be",
            23: "this",
            24: "have",
            25: "from",
            26: "or",
            27: "one",
            28: "had",
            29: "by",
            30: "word",
            31: "but",
            32: "not",
            33: "what",
            34: "all",
            35: "were",
            36: "we",
            37: "when",
            38: "your",
            39: "can",
            40: "said",
            41: "there",
            42: "each",
            43: "which",
            44: "she",
            45: "do",
            46: "how",
            47: "their",
            48: "if",
            49: "will",
            50: "up",
            51: "other",
            52: "about",
            53: "out",
            54: "many",
            55: "then",
            56: "them",
            57: "these",
            58: "so",
            59: "some",
            60: "her",
            61: "would",
            62: "make",
            63: "like",
            64: "into",
            65: "him",
            66: "has",
            67: "two",
            68: "more",
            69: "go",
            70: "no",
            71: "way",
            72: "could",
            73: "my",
            74: "than",
            75: "first",
            76: "been",
            77: "call",
            78: "who",
            79: "its",
            80: "now",
            81: "find",
            82: "long",
            83: "down",
            84: "day",
            85: "did",
            86: "get",
            87: "come",
            88: "made",
            89: "may",
            90: "part",
            // Journal-specific words
            100: "feel",
            101: "feeling",
            102: "today",
            103: "think",
            104: "thinking",
            105: "about",
            106: "really",
            107: "just",
            108: "like",
            109: "need",
            110: "want",
            111: "know",
            112: "life",
            113: "back",
            114: "going",
            115: "home",
            116: "work",
            117: "time",
            118: "good",
            119: "still",
            120: "again",
            121: "much",
            122: "well",
            // Punctuation (using higher numbers to avoid conflicts)
            250: ".",
            251: ",",
            252: "!",
            253: "?",
            254: "\n"
        ]
        
        // Try our custom mapping first, fall back to original vocabulary
        var decoded = ""
        for token in tokens {
            if let mappedToken = gpt2TokenMap[token] {
                decoded += mappedToken
                print("✅ Mapped token \(token) -> '\(mappedToken)'")
            } else if let originalToken = reverseVocabulary[token] {
                decoded += originalToken
                print("📝 Original token \(token) -> '\(originalToken)'")
            } else {
                // Unknown token, use a placeholder
                decoded += "[UNK]"
                print("❓ Unknown token: \(token)")
            }
        }
        
        // Clean up spacing
        var cleaned = decoded
            .replacingOccurrences(of: "Ġ", with: " ")
            .replacingOccurrences(of: "Ċ", with: "\n")
            .replacingOccurrences(of: "  ", with: " ") // Remove double spaces
        
        print("🎯 Final decoded text: '\(cleaned)'")
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
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
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    
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
            
            // Approach 1: Look for compiled .mlmodelc (most common in app bundle)
            modelURL = Bundle.main.url(forResource: "gpt2-512", withExtension: "mlmodelc")
            if modelURL != nil {
                print("✅ Found compiled .mlmodelc model in bundle")
            }
            
            // Approach 2: Look for original .mlmodel (less common in bundle)
            if modelURL == nil {
                modelURL = Bundle.main.url(forResource: "gpt2-512", withExtension: "mlmodel")
                if modelURL != nil {
                    print("✅ Found original .mlmodel in bundle")
                } else {
                    print("⚠️ Model not found with standard bundle lookup")
                }
            }
            
            // Approach 3: Try without extension
            if modelURL == nil {
                modelURL = Bundle.main.url(forResource: "gpt2-512.mlmodelc", withExtension: nil)
                if modelURL != nil {
                    print("✅ Found compiled model without extension")
                } else {
                    print("⚠️ Model not found with extension included")
                }
            }
            
            // Approach 4: Search all bundle URLs for both extensions
            if modelURL == nil {
                print("🔍 Searching for any Core ML models in bundle...")
                
                // Search for compiled models first
                let compiledModels = Bundle.main.urls(forResourcesWithExtension: "mlmodelc", subdirectory: nil)
                print("🔎 Found \(compiledModels?.count ?? 0) .mlmodelc files in bundle:")
                compiledModels?.forEach { url in
                    print("   - \(url.lastPathComponent)")
                }
                modelURL = compiledModels?.first { $0.lastPathComponent.contains("gpt2") }
                
                // Search for original models if no compiled ones found
                if modelURL == nil {
                    let originalModels = Bundle.main.urls(forResourcesWithExtension: "mlmodel", subdirectory: nil)
                    print("🔎 Found \(originalModels?.count ?? 0) .mlmodel files in bundle:")
                    originalModels?.forEach { url in
                        print("   - \(url.lastPathComponent)")
                    }
                    modelURL = originalModels?.first { $0.lastPathComponent.contains("gpt2") }
                }
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
        
        print("🤖 Starting GPT-2 generation for prompt: '\(prompt.prefix(50))...'")
        
        // Start generation progress tracking
        isGenerating = true
        generationProgress = 0.0
        
        defer {
            isGenerating = false
            generationProgress = 0.0
        }
        
        do {
            // Tokenize the input prompt
            var tokens = tokenizer.encode(prompt)
            let originalLength = tokens.count
            print("📝 Tokenized prompt to \(originalLength) tokens: \(tokens.prefix(10))")
            
            // Ensure we have some input tokens
            if tokens.isEmpty {
                tokens = [tokenizer.encode("Today")[0]] // Fallback
                print("⚠️ Empty tokens, using fallback")
            }
            
            var generationSteps = 0
            let maxSteps = min(maxLength, 20) // Reduced for initial testing
            
            // Generate tokens one by one (autoregressive)
            for step in 0..<maxSteps {
                // Update progress
                generationProgress = Double(step) / Double(maxSteps)
                
                print("🔄 Generation step \(step + 1)/\(maxSteps)")
                let inputArray = createInputArray(from: tokens)
                
                // Run inference
                let prediction = try await model.prediction(from: inputArray)
                print("🧠 Model prediction completed, extracting token...")
                
                // Debug: Print available output features
                print("📊 Available prediction features: \(prediction.featureNames)")
                
                // Extract the next token from the model output
                if let nextToken = extractNextToken(from: prediction, currentPosition: tokens.count - 1) {
                    print("✅ Extracted token: \(nextToken)")
                    tokens.append(nextToken)
                    generationSteps += 1
                    
                    // Stop on end of text token
                    if nextToken == 50256 { // <|endoftext|>
                        print("🛑 Hit end-of-text token, stopping generation")
                        break
                    }
                } else {
                    print("❌ Failed to extract next token, stopping generation")
                    break
                }
                
                // Add small delay to prevent UI blocking and allow UI updates
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds for progress visibility
            }
            
            // Complete progress
            generationProgress = 1.0
            
            print("🏁 Generation completed. Generated \(generationSteps) new tokens")
            
            // Decode only the generated portion
            let generatedTokens = Array(tokens[originalLength...])
            print("🔤 Generated tokens: \(generatedTokens)")
            let generatedText = tokenizer.decode(generatedTokens)
            print("📖 Decoded generated text: '\(generatedText)'")
            
            // Clean up and return
            let result = cleanupGeneratedText(prompt + generatedText)
            print("✨ Final result: '\(result.prefix(100))...'")
            return result
            
        } catch {
            print("❌ GPT-2 generation failed: \(error)")
            throw error
        }
    }
    
    private func createInputArray(from tokens: [Int]) -> MLFeatureProvider {
        // Create input for the GPT-2 model
        // Most GPT-2 Core ML models expect input_ids as Int32 array
        let maxSequenceLength = 512 // Based on model name gpt2-512
        let paddedTokens = padTokens(tokens, to: maxSequenceLength)
        
        do {
            // Create input_ids array (must be rank 1, not rank 2)
            let inputArray = try MLMultiArray(shape: [NSNumber(value: maxSequenceLength)], dataType: .int32)
            for (i, token) in paddedTokens.enumerated() {
                inputArray[i] = NSNumber(value: token)
            }
            
            // Create position_ids array (required by this GPT-2 model)
            // Note: Must be rank 1 (1-dimensional), not rank 2
            let positionArray = try MLMultiArray(shape: [NSNumber(value: maxSequenceLength)], dataType: .int32)
            for i in 0..<maxSequenceLength {
                positionArray[i] = NSNumber(value: i)
            }
            
            print("📊 Created input arrays: input_ids[\(maxSequenceLength)], position_ids[\(maxSequenceLength)]")
            
            let featureDict: [String: Any] = [
                "input_ids": inputArray,
                "position_ids": positionArray
            ]
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
    
    private func extractNextToken(from prediction: MLFeatureProvider, currentPosition: Int) -> Int? {
        // Try common output names for GPT-2 models
        let possibleOutputNames = ["output", "logits", "prediction", "next_token", "output_0", "1374"]
        
        print("🔍 Trying to extract token from prediction features: \(prediction.featureNames)")
        
        for outputName in possibleOutputNames {
            if let output = prediction.featureValue(for: outputName)?.multiArrayValue {
                print("✅ Found output feature '\(outputName)' with shape: \(output.shape)")
                return extractTokenFromLogits(output, currentPosition: currentPosition)
            } else {
                print("❌ No output found for '\(outputName)'")
            }
        }
        
        // Try to find any MLMultiArray output
        print("🔎 Trying first available feature...")
        if let firstOutput = prediction.featureNames.first {
            print("📊 First feature name: '\(firstOutput)'")
            if let output = prediction.featureValue(for: firstOutput)?.multiArrayValue {
                print("✅ Using first feature with shape: \(output.shape)")
                return extractTokenFromLogits(output, currentPosition: currentPosition)
            }
        }
        
        print("❌ No suitable output feature found")
        return nil
    }
    
    private func extractTokenFromLogits(_ logits: MLMultiArray, currentPosition: Int) -> Int? {
        print("🧮 Extracting token from logits with shape: \(logits.shape), count: \(logits.count)")
        
        // Find the token with highest probability
        var maxValue: Float = -Float.infinity
        var bestToken = 0
        
        let count = logits.count
        let dataPointer = logits.dataPointer.bindMemory(to: Float.self, capacity: count)
        
        // For GPT-2, the output might be [batch_size, sequence_length, vocab_size, extra_dims...]
        // We need to extract from the last sequence position
        let shape = logits.shape.map { $0.intValue }
        print("📐 Logits shape: \(shape)")
        
        if shape.count == 5 && shape[0] == 1 && shape[3] == 1 && shape[4] == 1 {
            // Shape is [1, sequence, vocab, 1, 1] - GPT-2 specific format
            let seqLength = shape[1] 
            let vocabSize = shape[2]
            print("📊 5D tensor: batch=1, seq=\(seqLength), vocab=\(vocabSize), extra=(1,1)")
            print("📍 Using current position: \(currentPosition)")
            
            // Use the current position in the sequence (where we just added the last token)
            let usePosition = min(currentPosition, seqLength - 1)
            
            // Calculate stride for 5D tensor: [batch, seq, vocab, 1, 1]
            // Index = batch * (seq * vocab * 1 * 1) + seq * (vocab * 1 * 1) + vocab * (1 * 1) + 0 * 1 + 0
            let seqStride = vocabSize * 1 * 1  // vocab * 1 * 1
            let baseIndex = usePosition * seqStride
            
            print("🎯 Extracting from position \(usePosition), baseIndex: \(baseIndex)")
            
            for i in 0..<min(vocabSize, 50257) { // GPT-2 vocab size is 50257
                let logitIndex = baseIndex + i
                if logitIndex < count {
                    let value = dataPointer[logitIndex]
                    if value > maxValue {
                        maxValue = value
                        bestToken = i
                    }
                }
            }
        } else if shape.count == 3 {
            // Shape is [batch, sequence, vocab] - use last sequence position
            let batchSize = shape[0]
            let seqLength = shape[1] 
            let vocabSize = shape[2]
            print("📊 3D tensor: batch=\(batchSize), seq=\(seqLength), vocab=\(vocabSize)")
            
            // Get logits from last position in sequence
            let lastPosStart = (seqLength - 1) * vocabSize
            
            for i in 0..<min(vocabSize, 50257) {
                let logitIndex = lastPosStart + i
                if logitIndex < count {
                    let value = dataPointer[logitIndex]
                    if value > maxValue {
                        maxValue = value
                        bestToken = i
                    }
                }
            }
        } else if shape.count == 2 {
            // Shape is [sequence, vocab] - use last sequence position
            let seqLength = shape[0]
            let vocabSize = shape[1]
            print("📊 2D tensor: seq=\(seqLength), vocab=\(vocabSize)")
            
            let lastPosStart = (seqLength - 1) * vocabSize
            
            for i in 0..<min(vocabSize, 50257) {
                let logitIndex = lastPosStart + i
                if logitIndex < count {
                    let value = dataPointer[logitIndex]
                    if value > maxValue {
                        maxValue = value
                        bestToken = i
                    }
                }
            }
        } else {
            // Fallback: treat as flat vocab distribution
            print("📊 Flat tensor, assuming vocab distribution")
            let vocabSize = min(count, 50257)
            
            for i in 0..<vocabSize {
                let value = dataPointer[i]
                if value > maxValue {
                    maxValue = value
                    bestToken = i
                }
            }
        }
        
        print("🎯 Selected token: \(bestToken) with confidence: \(maxValue)")
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
    
    func generateContextualText(prompt: String, recentEntries: [String], realityLevel: Double) async throws -> String {
        // If model is available, use it with contextual prompt
        if isModelLoaded {
            return try await generateText(prompt: prompt, maxLength: 150)
        } else {
            // Use intelligent fallback that mimics style
            return generateIntelligentFallback(prompt: prompt, recentEntries: recentEntries, realityLevel: realityLevel)
        }
    }
    
    private func generateIntelligentFallback(prompt: String, recentEntries: [String], realityLevel: Double) -> String {
        // Analyze recent entries to generate contextually appropriate continuation
        let styleAnalysis = analyzeWritingStyle(recentEntries)
        let thematicContext = extractThemes(recentEntries)
        
        return generateStyledContinuation(
            prompt: prompt,
            style: styleAnalysis,
            themes: thematicContext,
            realityLevel: realityLevel
        )
    }
    
    private func analyzeWritingStyle(_ entries: [String]) -> WritingStyleContext {
        guard !entries.isEmpty else {
            return WritingStyleContext(casualness: 0.5, sentenceLength: "moderate", vocabulary: "accessible")
        }
        
        let combinedText = entries.joined(separator: " ")
        let avgSentenceLength = calculateSentenceLength(combinedText)
        let casualnessScore = detectCasualness(combinedText)
        let vocabLevel = analyzeVocabulary(combinedText)
        
        return WritingStyleContext(
            casualness: casualnessScore,
            sentenceLength: avgSentenceLength < 10 ? "short" : avgSentenceLength > 20 ? "long" : "moderate",
            vocabulary: vocabLevel > 0.7 ? "sophisticated" : vocabLevel > 0.4 ? "accessible" : "simple"
        )
    }
    
    private func extractThemes(_ entries: [String]) -> [String] {
        let themeKeywords = [
            "work": ["work", "job", "meeting", "colleague", "boss", "office", "deadline"],
            "relationships": ["friend", "family", "mom", "dad", "relationship", "love"],
            "daily": ["morning", "coffee", "sleep", "home", "routine", "tired"],
            "emotions": ["happy", "sad", "stressed", "excited", "worried", "calm"],
            "reflection": ["thinking", "realized", "feel", "wonder", "understand"]
        ]
        
        let combinedText = entries.joined(separator: " ").lowercased()
        var themeScores: [String: Int] = [:]
        
        for (theme, keywords) in themeKeywords {
            let score = keywords.reduce(0) { count, keyword in
                count + combinedText.components(separatedBy: keyword).count - 1
            }
            themeScores[theme] = score
        }
        
        return themeScores.sorted { $0.value > $1.value }.prefix(2).map { $0.key }
    }
    
    private func generateStyledContinuation(prompt: String, style: WritingStyleContext, themes: [String], realityLevel: Double) -> String {
        let continuationStarters = style.casualness > 0.5 ? 
            ["honestly", "like", "anyway", "so basically", "i guess", "kinda feels like"] :
            ["I find myself", "There's something", "What strikes me", "I've been thinking", "It occurs to me"]
        
        let themeBasedContent = generateThemeBasedContent(themes: themes, realityLevel: realityLevel, style: style)
        
        let starter = continuationStarters.randomElement() ?? "I think"
        let connector = style.casualness > 0.5 ? "..." : "."
        
        var continuation = " \(starter.capitalized) \(themeBasedContent)\(connector)"
        
        // Add second sentence if style allows longer content
        if style.sentenceLength != "short" {
            let secondPart = generateSecondSentence(themes: themes, style: style)
            continuation += " \(secondPart)"
        }
        
        return prompt + continuation
    }
    
    private func generateThemeBasedContent(themes: [String], realityLevel: Double, style: WritingStyleContext) -> String {
        let isCreative = realityLevel < 0.5
        
        let contentMap: [String: [String]] = [
            "work": isCreative ? 
                ["my job feels like performance art", "the office exists in some parallel dimension", "meetings are elaborate social experiments"] :
                ["work was actually productive today", "had a good conversation with my colleague", "finally finished that project"],
                
            "relationships": isCreative ?
                ["people are beautiful puzzles", "conversations feel like collaborative storytelling", "human connection is this wild mystery"] :
                ["talked to my friend about life stuff", "family dinner was nice", "feeling grateful for good people"],
                
            "daily": isCreative ?
                ["morning routines are tiny rituals of hope", "coffee tastes like liquid possibility", "sleep is where reality gets interesting"] :
                ["morning was quiet and peaceful", "coffee was perfect today", "sleep actually felt restful"],
                
            "emotions": isCreative ?
                ["feelings are like weather patterns in my chest", "emotions have their own logic", "mood shifts feel like changing seasons"] :
                ["feeling pretty good about things", "emotions are complicated but manageable", "learning to sit with difficult feelings"],
                
            "reflection": isCreative ?
                ["consciousness is this ongoing conversation", "thoughts have their own ecosystem", "awareness keeps surprising me"] :
                ["been thinking about what really matters", "reflecting on recent experiences", "trying to understand my reactions"]
        ]
        
        let primaryTheme = themes.first ?? "reflection"
        let options = contentMap[primaryTheme] ?? contentMap["reflection"]!
        
        return options.randomElement() ?? "about the complexity of daily experience"
    }
    
    private func generateSecondSentence(themes: [String], style: WritingStyleContext) -> String {
        let casual = [
            "pretty wild how that works",
            "not sure what to make of it yet",
            "still processing all of this",
            "life keeps teaching me stuff"
        ]
        
        let formal = [
            "The implications are still unfolding.",
            "I'm curious to see where this leads.",
            "There's more to explore here.",
            "This deserves further reflection."
        ]
        
        let options = style.casualness > 0.5 ? casual : formal
        return options.randomElement() ?? "There's always more to discover."
    }
    
    // Helper method to detect gibberish text
    private func isGibberish(_ text: String) -> Bool {
        // Check if text is mostly non-alphabetic characters
        let alphaCount = text.filter { $0.isLetter }.count
        let totalCount = text.count
        
        if totalCount == 0 { return true }
        
        let alphaRatio = Double(alphaCount) / Double(totalCount)
        
        // If less than 30% alphabetic characters, likely gibberish
        if alphaRatio < 0.3 { return true }
        
        // Check for excessive punctuation or symbols
        let symbolCount = text.filter { "!@#$%^&*()+={}[]|\\:;\"'<>?/~`".contains($0) }.count
        let symbolRatio = Double(symbolCount) / Double(totalCount)
        
        // If more than 50% symbols, likely gibberish
        return symbolRatio > 0.5
    }
    
    // Helper methods
    private func calculateSentenceLength(_ text: String) -> Double {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?")).filter { !$0.isEmpty }
        guard !sentences.isEmpty else { return 10.0 }
        
        let totalWords = sentences.reduce(0) { count, sentence in
            count + sentence.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        }
        
        return Double(totalWords) / Double(sentences.count)
    }
    
    private func detectCasualness(_ text: String) -> Double {
        let casualIndicators = ["like", "kinda", "gonna", "yeah", "lol", "tbh", "omg", "don't", "can't", "isn't"]
        let lowerText = text.lowercased()
        
        let casualCount = casualIndicators.reduce(0) { count, indicator in
            count + lowerText.components(separatedBy: indicator).count - 1
        }
        
        let totalWords = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        return totalWords > 0 ? min(Double(casualCount) / Double(totalWords), 1.0) : 0.0
    }
    
    private func analyzeVocabulary(_ text: String) -> Double {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        guard !words.isEmpty else { return 0.5 }
        
        let uniqueWords = Set(words.map { $0.lowercased() })
        return Double(uniqueWords.count) / Double(words.count)
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

// MARK: - Supporting Types

struct WritingStyleContext {
    let casualness: Double
    let sentenceLength: String
    let vocabulary: String
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