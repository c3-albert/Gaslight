#!/usr/bin/env swift

import Foundation

// MARK: - Copied Components from AIEntryGenerator for Testing

struct PromptComponents {
    let character: String
    let setting: String
    let action: String
    let discovery: String
    let starter: String
    let mood: String
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var seed: UInt64
    
    init(seed: Int) {
        self.seed = UInt64(abs(seed))
    }
    
    mutating func next() -> UInt64 {
        seed = seed &* 1103515245 &+ 12345
        return seed
    }
}

class ProceduralPromptTester {
    
    // MARK: - Test Seed Generation (Simulated)
    
    private func createTestSeed(day: Int, deviceId: Int, launchCount: Int, battery: Int) -> Int {
        let dateSeed = 25000 + day // Simulate year 2025, various days
        let deviceSeed = deviceId % 10000
        let launchCountSeed = launchCount % 10000
        let batterySeed = battery % 1000
        
        return (dateSeed * 31 + deviceSeed * 17 + launchCountSeed * 13 + batterySeed * 7) % Int.max
    }
    
    // MARK: - Component Pools (Copied from AIEntryGenerator)
    
    private func getCharacterPool(realityLevel: Double) -> [String] {
        let base = ["coffee mug", "houseplant", "favorite pen", "smartphone", "reflection", "shadow", "bookshelf", "alarm clock"]
        let fantastical = ["tiny dragon", "house brownie", "talking bird", "wise spider", "helpful ghost", "library fairy"]
        let whimsical = ["old journal", "reading glasses", "tea kettle", "desk lamp", "favorite sweater", "kitchen timer"]
        
        if realityLevel < 0.3 {
            return base + fantastical + fantastical
        } else if realityLevel < 0.6 {
            return base + fantastical + whimsical
        } else {
            return base + whimsical + whimsical
        }
    }
    
    private func getSettingPool(realityLevel: Double) -> [String] {
        let base = ["sock drawer", "kitchen counter", "bookshelf", "bathroom mirror", "desk", "windowsill", "closet", "nightstand"]
        let fantastical = ["secret portal behind the books", "hidden room under the stairs", "magical garden shed", "enchanted attic space"]
        let whimsical = ["reading nook", "coffee corner", "writing desk", "favorite chair", "cozy blanket fort", "sunny window spot"]
        
        if realityLevel < 0.3 {
            return base + fantastical
        } else if realityLevel < 0.6 {
            return base + fantastical + whimsical
        } else {
            return base + whimsical
        }
    }
    
    private func getActionPool(realityLevel: Double) -> [String] {
        let base = ["organizing things", "holding meetings", "planning surprises", "keeping secrets", "solving problems", "making improvements"]
        let fantastical = ["casting helpful spells", "running a tiny government", "operating a postal service", "conducting midnight concerts", "hosting interdimensional tea parties"]
        let whimsical = ["leaving encouraging notes", "rearranging things thoughtfully", "creating pleasant coincidences", "orchestrating serendipitous moments"]
        
        if realityLevel < 0.3 {
            return base + fantastical
        } else if realityLevel < 0.6 {
            return base + fantastical + whimsical
        } else {
            return base + whimsical
        }
    }
    
    private func getDiscoveryPool(realityLevel: Double) -> [String] {
        let base = ["This changes everything about how I see my daily routine.", "I've been living alongside this secret world without knowing it.", "The signs were always there, but I never paid attention."]
        let fantastical = ["Magic has been happening right under my nose this entire time.", "I'm apparently living in a much more interesting universe than I thought.", "Reality is far more flexible than anyone ever told me."]
        let whimsical = ["There's so much more personality in my surroundings than I realized.", "My home has been quietly taking care of me in ways I never noticed.", "Life has been full of tiny miracles I was too busy to see."]
        
        if realityLevel < 0.3 {
            return base + fantastical
        } else if realityLevel < 0.6 {
            return base + fantastical + whimsical
        } else {
            return base + whimsical
        }
    }
    
    private func getStarterPool(realityLevel: Double) -> [String] {
        let base = ["I always wondered why", "I should have realized when", "Looking back, the clues were obvious:", "It started when I noticed"]
        let fantastical = ["The impossible happened when", "Magic revealed itself the moment", "Reality shifted completely when", "The ordinary world cracked open as"]
        let whimsical = ["Something beautiful happened when", "A gentle mystery unfolded as", "I felt like I was in a story when", "The most wonderful thing occurred:"]
        
        if realityLevel < 0.3 {
            return base + fantastical
        } else if realityLevel < 0.6 {
            return base + fantastical + whimsical
        } else {
            return base + whimsical
        }
    }
    
    private func getMoodPool(realityLevel: Double) -> [String] {
        let base = ["unexpected", "delightful", "mysterious", "surprising", "curious", "enchanting"]
        let fantastical = ["magical", "impossible", "otherworldly", "fantastical", "supernatural", "extraordinary"]
        let whimsical = ["heartwarming", "charming", "gentle", "cozy", "wonderful", "serendipitous"]
        
        if realityLevel < 0.3 {
            return base + fantastical
        } else if realityLevel < 0.6 {
            return base + fantastical + whimsical
        } else {
            return base + whimsical
        }
    }
    
    // MARK: - Generation Logic
    
    private func selectPromptComponents(realityLevel: Double, generator: inout SeededRandomNumberGenerator) -> PromptComponents {
        let characters = getCharacterPool(realityLevel: realityLevel)
        let settings = getSettingPool(realityLevel: realityLevel)
        let actions = getActionPool(realityLevel: realityLevel)
        let discoveries = getDiscoveryPool(realityLevel: realityLevel)
        let starters = getStarterPool(realityLevel: realityLevel)
        let moods = getMoodPool(realityLevel: realityLevel)
        
        return PromptComponents(
            character: characters.randomElement(using: &generator)!,
            setting: settings.randomElement(using: &generator)!,
            action: actions.randomElement(using: &generator)!,
            discovery: discoveries.randomElement(using: &generator)!,
            starter: starters.randomElement(using: &generator)!,
            mood: moods.randomElement(using: &generator)!
        )
    }
    
    private func buildPromptFromComponents(_ components: PromptComponents) -> String {
        return """
        You are a journal writer documenting \(components.mood) encounters. Today you discovered that your \(components.character) has been secretly \(components.action) in your \(components.setting). \(components.discovery) Write about this revelation and what you learned. Begin with: '\(components.starter)'
        """
    }
    
    private func generateProceduralPrompt(realityLevel: Double, seed: Int) -> String {
        var generator = SeededRandomNumberGenerator(seed: seed)
        let components = selectPromptComponents(realityLevel: realityLevel, generator: &generator)
        return buildPromptFromComponents(components)
    }
    
    // MARK: - Test Runner
    
    func runTests() -> String {
        var output = "# Procedural Prompt Generation Test Results\n\n"
        output += "Generated on: \(Date())\n\n"
        output += "Testing the new 4-factor seed system with various combinations:\n"
        output += "- **Date Factor**: Simulated different days\n"
        output += "- **Device Factor**: Different simulated device IDs\n"
        output += "- **Launch Count**: Various app launch counts\n"
        output += "- **Battery Level**: Different battery percentages\n\n"
        
        // Test 1: Same day, different conditions
        output += "## Test 1: Same Day, Different User Conditions\n\n"
        output += "*Testing variety within a single day with different device/usage patterns*\n\n"
        
        let testConfigs = [
            (device: 1234, launch: 5, battery: 85, label: "User A, 5th launch, 85% battery"),
            (device: 1234, launch: 6, battery: 84, label: "User A, 6th launch, 84% battery"),
            (device: 5678, launch: 5, battery: 85, label: "User B, 5th launch, 85% battery"),
            (device: 1234, launch: 15, battery: 45, label: "User A, 15th launch, 45% battery")
        ]
        
        for (i, config) in testConfigs.enumerated() {
            let seed = createTestSeed(day: 1, deviceId: config.device, launchCount: config.launch, battery: config.battery)
            let prompt = generateProceduralPrompt(realityLevel: 0.2, seed: seed) // Low reality = fantastical
            
            output += "### \(i + 1). \(config.label)\n"
            output += "**Seed**: \(seed)\n\n"
            output += "**Generated Prompt**:\n"
            output += "```\n\(prompt)\n```\n\n"
        }
        
        // Test 2: Different reality levels, same conditions
        output += "## Test 2: Different Reality Levels, Same Conditions\n\n"
        output += "*Testing how reality level affects prompt style*\n\n"
        
        let realityLevels: [(level: Double, label: String)] = [
            (0.1, "Very Fantastical (10%)"),
            (0.4, "Moderately Magical (40%)"),
            (0.8, "Whimsical but Grounded (80%)")
        ]
        
        let fixedSeed = createTestSeed(day: 2, deviceId: 9999, launchCount: 10, battery: 75)
        
        for (level, label) in realityLevels {
            let prompt = generateProceduralPrompt(realityLevel: level, seed: fixedSeed)
            
            output += "### \(label)\n"
            output += "**Reality Level**: \(level)\n\n"
            output += "**Generated Prompt**:\n"
            output += "```\n\(prompt)\n```\n\n"
        }
        
        // Test 3: Different days
        output += "## Test 3: Daily Variation\n\n"
        output += "*Testing how prompts change across different days*\n\n"
        
        for day in 1...5 {
            let seed = createTestSeed(day: day, deviceId: 1111, launchCount: 8, battery: 70)
            let prompt = generateProceduralPrompt(realityLevel: 0.5, seed: seed)
            
            output += "### Day \(day) (Mid-Reality 50%)\n"
            output += "**Seed**: \(seed)\n\n"
            output += "**Generated Prompt**:\n"
            output += "```\n\(prompt)\n```\n\n"
        }
        
        // Test 4: Collision testing
        output += "## Test 4: Uniqueness Analysis\n\n"
        output += "*Testing for potential prompt collisions with similar inputs*\n\n"
        
        var generatedPrompts: Set<String> = []
        var collisionCount = 0
        let testIterations = 50
        
        for i in 1...testIterations {
            let seed = createTestSeed(day: i % 7 + 1, deviceId: i * 17, launchCount: i, battery: (i * 13) % 100)
            let prompt = generateProceduralPrompt(realityLevel: Double(i % 10) / 10.0, seed: seed)
            
            if generatedPrompts.contains(prompt) {
                collisionCount += 1
            } else {
                generatedPrompts.insert(prompt)
            }
        }
        
        output += "**Test Results**:\n"
        output += "- Generated \(testIterations) prompts\n"
        output += "- Unique prompts: \(generatedPrompts.count)\n"
        output += "- Collisions: \(collisionCount)\n"
        output += "- Uniqueness rate: \(String(format: "%.1f", (Double(generatedPrompts.count) / Double(testIterations)) * 100))%\n\n"
        
        if collisionCount > 0 {
            output += "⚠️ Found \(collisionCount) collisions - may need to increase entropy sources or improve mixing.\n\n"
        } else {
            output += "✅ Perfect uniqueness - no collisions detected!\n\n"
        }
        
        // Sample unique prompts for variety demonstration
        output += "## Sample Generated Prompts for Variety Review\n\n"
        
        let sampleSeeds = [12345, 67890, 24680, 13579, 98765, 55555, 77777, 33333]
        for (i, seed) in sampleSeeds.enumerated() {
            let realityLevel = [0.15, 0.25, 0.45, 0.65, 0.75, 0.85].randomElement() ?? 0.5
            let prompt = generateProceduralPrompt(realityLevel: realityLevel, seed: seed)
            
            output += "### Sample \(i + 1) (Reality: \(Int(realityLevel * 100))%)\n"
            output += "```\n\(prompt)\n```\n\n"
        }
        
        return output
    }
}

// Run the test
let tester = ProceduralPromptTester()
let results = tester.runTests()
print(results)