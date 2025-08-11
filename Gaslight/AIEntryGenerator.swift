//
//  AIEntryGenerator.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import Foundation
import UIKit

enum AIGenerationMode {
    case templates
    case coreML
    case hybrid
}

@MainActor
class AIEntryGenerator: ObservableObject {
    static let shared = AIEntryGenerator()
    
    @Published var generationMode: AIGenerationMode = .hybrid
    private let coreMLGenerator = CoreMLTextGenerator.shared
    private let onDeviceGenerator = OnDeviceAIGenerator.shared
    
    private init() {}
    
    // MARK: - Authentic Journal Templates
    
    private let realisticTemplates = [
        "{time_start} and already {daily_struggle}. {weather_reaction}",
        "ugh {mundane_complaint}... {time_period} later still thinking about it",
        "{person} {social_interaction} today. {emotional_reaction}",
        "tried to {simple_task} but {minor_failure}. whatever, {coping_mechanism}",
        "{meal_situation}. {food_thoughts}",
        "commute was {commute_descriptor}. {transport_thoughts}",
        "{sleep_situation} last night. {tired_complaint}",
        "{work_feeling} at work today. {colleague} was {colleague_behavior}",
        "mom called {family_interaction}. {family_feelings}",
        "{weather} so {weather_activity}. {mood_weather_connection}",
        "spent too much time {time_waste}. {self_judgment}",
        "{random_observation} while {routine_activity}",
        "need to {procrastinated_task} but {excuse}. tomorrow maybe?",
        "{purchase_decision}. {buyer_remorse}",
        "{social_media_observation}. why do i even {social_media_behavior}"
    ]
    
    private let surrealistTemplates = [
        "my {object} started {weird_behavior} again. neighbors probably think {assumption}",
        "had full conversation with {inanimate_thing} about {deep_topic}. made some good points actually",
        "{impossible_thing} happened while {mundane_activity}. tuesday's are weird",
        "discovered ive been {unconscious_habit} for {time_period}. explains {random_connection}",
        "woke up and {dream_reality_confusion}. reality is {reality_assessment}",
        "{object} gave me {life_advice} today. honestly not wrong",
        "tried to explain {simple_concept} to {pet_or_plant}. they {reaction}",
        "{philosophical_realization} hit me during {boring_activity}. universe is {universe_assessment}"
    ]
    
    private let templateVariables: [String: [String]] = [
        // Realistic daily life
        "time_start": ["8am", "way too early", "noon already", "3pm somehow", "evening", "late last night"],
        "daily_struggle": ["spilled coffee", "missed the bus", "forgot my keys", "phone died", "ran out of milk", "overslept again"],
        "weather_reaction": ["at least its not raining", "too hot for this", "perfect sweater weather", "why is it so windy", "should've checked the weather"],
        "mundane_complaint": ["forgot lunch money", "laundry piling up", "need groceries", "dishes in the sink", "wifi is slow", "neighbors being loud"],
        "time_period": ["20 minutes", "an hour", "way too long", "the whole morning", "like 3 seconds", "forever"],
        "person": ["sarah", "that guy from work", "my roommate", "the cashier", "some random person", "my mom obviously"],
        "social_interaction": ["texted me", "called out of nowhere", "was being weird", "asked about plans", "said something funny", "ignored my message"],
        "emotional_reaction": ["kinda annoyed but whatever", "made me laugh", "was actually really nice", "awkward as usual", "reminded me why i like them", "idk how to feel about it"],
        "simple_task": ["do laundry", "grocery shop", "clean my room", "call the dentist", "organize my desk", "plan the weekend"],
        "minor_failure": ["forgot the list", "got distracted", "took too long", "made it worse", "gave up halfway", "ordered takeout instead"],
        "coping_mechanism": ["gonna try again tomorrow", "at least i tried", "ordered pizza", "took a nap", "called it good enough", "pretended it didnt happen"],
        "meal_situation": ["cereal for dinner again", "made actual food today", "too lazy to cook", "tried a new recipe", "ate leftovers", "skipped breakfast"],
        "food_thoughts": ["actually pretty good", "shouldve added salt", "why do i do this to myself", "reminded me of moms cooking", "definitely ordering out tomorrow", "proud of myself tbh"],
        "commute_descriptor": ["terrible", "actually ok", "way too crowded", "longer than usual", "surprisingly smooth", "a whole mess"],
        "transport_thoughts": ["need better music", "everyone looks tired", "wish i could work from home", "at least i have coffee", "people are weird", "love this route actually"],
        "sleep_situation": ["couldnt sleep", "slept too much", "weird dreams", "phone kept buzzing", "neighbors were loud", "actually slept great"],
        "tired_complaint": ["feel like garbage", "need more coffee", "why am i like this", "shouldve gone to bed earlier", "gonna nap later", "zombie mode activated"],
        "work_feeling": ["meh", "actually productive", "completely overwhelmed", "bored out of my mind", "stressed about deadlines", "weirdly motivated"],
        "colleague": ["mike", "that new person", "my boss", "everyone", "the intern", "jessica from accounting"],
        "colleague_behavior": ["being extra", "actually helpful", "complaining again", "in a good mood", "stressed about something", "making weird jokes"],
        "family_interaction": ["to check in", "with drama", "asking about my life", "being supportive", "worrying about nothing", "with random updates"],
        "family_feelings": ["love her but omg", "actually needed that", "reminded me to call more", "she worries too much", "made me homesick", "classic mom"],
        "weather": ["raining", "sunny", "gray and depressing", "perfect outside", "too humid", "actually nice"],
        "weather_activity": ["stayed inside", "went for a walk", "opened all the windows", "regretted wearing jeans", "perfect for coffee", "made me sleepy"],
        "mood_weather_connection": ["matches my mood", "too cheerful for how i feel", "exactly what i needed", "making me lazy", "at least something's nice today", "cant complain"],
        "time_waste": ["on my phone", "watching random videos", "reorganizing stuff", "online shopping", "reading wikipedia", "staring at nothing"],
        "self_judgment": ["no regrets", "should be more productive", "time well spent honestly", "my attention span is terrible", "at least i enjoyed it", "procrastination level expert"],
        "random_observation": ["people are weird", "everything is expensive", "technology is crazy", "time goes by so fast", "life is random", "patterns are everywhere"],
        "routine_activity": ["brushing teeth", "making coffee", "walking to work", "doing dishes", "checking email", "getting dressed"],
        "procrastinated_task": ["call the doctor", "file taxes", "clean out closet", "respond to emails", "plan that trip", "organize photos"],
        "excuse": ["dont have time", "not in the mood", "its complicated", "need to research first", "waiting for inspiration", "kinda forgot"],
        "purchase_decision": ["bought unnecessary stuff", "finally got those shoes", "impulse bought snacks", "treated myself", "got the expensive version", "cheaper option was fine"],
        "buyer_remorse": ["worth it", "why did i do that", "actually pretty good", "couldve gotten it cheaper", "no regrets", "my wallet hates me"],
        "social_media_observation": ["everyone looks happy", "too much drama", "actually funny stuff today", "why do people post everything", "missing out on life", "algorithms are weird"],
        "social_media_behavior": ["scroll for hours", "post random stuff", "argue with strangers", "compare myself to others", "waste my time", "look at food pics"],
        
        // Surrealist elements
        "object": ["coffee mug", "houseplant", "toaster", "pen", "pillow", "phone", "mirror", "keys", "headphones", "water bottle"],
        "weird_behavior": ["giving life advice", "judging my choices", "being passive aggressive", "acting superior", "plotting something", "having opinions"],
        "assumption": ["im losing it", "im talking to objects", "i need help", "its normal", "im creative", "everyone does this"],
        "inanimate_thing": ["the mirror", "my coffee", "the houseplant", "my laptop", "the dishwasher", "the car"],
        "deep_topic": ["the meaning of life", "why people are weird", "what happiness means", "time management", "whether aliens exist", "why we procrastinate"],
        "impossible_thing": ["time stopped", "gravity reversed", "everyone read my mind", "colors changed", "sounds became visible", "reality glitched"],
        "mundane_activity": ["making toast", "checking email", "tying shoes", "brushing teeth", "opening doors", "turning on lights"],
        "unconscious_habit": ["humming the same song", "checking my phone every 30 seconds", "rearranging things", "talking to myself", "counting steps", "making weird faces"],
        "random_connection": ["why i lose socks", "my strange dreams", "why people avoid me", "my coffee addiction", "why traffic is always bad", "my commitment issues"],
        "dream_reality_confusion": ["everything was purple", "i could fly", "nothing made sense", "everyone was there", "time was weird", "i was someone else"],
        "reality_assessment": ["overrated", "confusing", "pretty weird", "not what i expected", "needs work", "hard to navigate"],
        "life_advice": ["stop overthinking", "embrace the chaos", "trust the process", "go with the flow", "question everything", "just be yourself"],
        "simple_concept": ["how monday works", "why people need sleep", "the point of small talk", "how emotions work", "why we need food", "basic human decency"],
        "pet_or_plant": ["my succulent", "the neighbor's cat", "this random bird", "my reflection", "the spider in the corner", "my imaginary friend"],
        "reaction": ["seemed interested", "judged me silently", "understood completely", "looked confused", "agreed surprisingly", "had better insights than me"],
        "philosophical_realization": ["nothing really matters", "everything is connected", "time is an illusion", "people are just trying their best", "life is weird but ok", "im exactly where i need to be"],
        "boring_activity": ["waiting in line", "sitting in traffic", "doing laundry", "staring at the ceiling", "watching ads", "waiting for food"],
        "universe_assessment": ["chaotic but beautiful", "probably laughing at us", "doing its best", "way too complicated", "full of surprises", "weirdly perfect"]
    ]
    
    func generateEntry(realityLevel: Double = 0.0) async -> String {
        switch generationMode {
        case .templates:
            return generateTemplateEntry(realityLevel: realityLevel)
        case .coreML:
            return await generateCoreMLEntry(realityLevel: realityLevel)
        case .hybrid:
            // Use modern on-device AI with device-appropriate fallbacks
            return await generateOnDeviceEntry(realityLevel: realityLevel)
        }
    }
    
    private func generateOnDeviceEntry(realityLevel: Double) async -> String {
        do {
            let prompt = createContextualPrompt(realityLevel: realityLevel)
            return try await onDeviceGenerator.generateJournalEntry(prompt: prompt, realityLevel: realityLevel)
        } catch {
            print("⚠️ On-device generation failed, using enhanced templates: \(error)")
            return generateEnhancedTemplateEntry(realityLevel: realityLevel)
        }
    }
    
    private func generateTemplateEntry(realityLevel: Double = 0.0) -> String {
        // Choose template based on reality level
        let template: String
        if realityLevel < 0.4 {
            // Low reality = surrealist templates
            template = surrealistTemplates.randomElement() ?? realisticTemplates.randomElement() ?? "today was weird"
        } else {
            // Higher reality = realistic templates
            template = realisticTemplates.randomElement() ?? "today was ok i guess"
        }
        
        var result = template
        
        // Replace template variables
        for (key, values) in templateVariables {
            let placeholder = "{\(key)}"
            if result.contains(placeholder),
               let randomValue = values.randomElement() {
                result = result.replacingOccurrences(of: placeholder, with: randomValue)
            }
        }
        
        // Add fragments and authentic touches
        result = addAuthenticTouches(to: result, realityLevel: realityLevel)
        
        return result
    }
    
    private func addAuthenticTouches(to text: String, realityLevel: Double) -> String {
        var result = text
        
        // Make text more fragmented and casual
        let casualConnectors = ["...", " idk ", " like ", " whatever ", " honestly ", " tbh "]
        let fragments = [" anyway", " so yeah", " but whatever", " i guess", " or not", " lol"]
        let timeJumps = ["\n\nupdate: ", "\n\nlater: ", "\n\n3 hours later... ", "\n\nmorning thoughts: "]
        
        // Add casual connectors randomly
        if Double.random(in: 0...1) < 0.3 {
            if let connector = casualConnectors.randomElement() {
                result += connector + generateShortFragment(realityLevel: realityLevel)
            }
        }
        
        // Add fragments
        if Double.random(in: 0...1) < 0.4 {
            if let fragment = fragments.randomElement() {
                result += fragment
            }
        }
        
        // Add time jumps for more complex entries
        if Double.random(in: 0...1) < 0.2 {
            if let timeJump = timeJumps.randomElement() {
                result += timeJump + generateShortFragment(realityLevel: realityLevel)
            }
        }
        
        // Sometimes make it lowercase and remove some punctuation for authenticity
        if Double.random(in: 0...1) < 0.6 {
            result = result.lowercased()
            result = result.replacingOccurrences(of: ".", with: "")
        }
        
        return result
    }
    
    private func generateShortFragment(realityLevel: Double) -> String {
        let shortFragments = [
            "still processing this",
            "need more coffee",
            "life is weird",
            "why do i do this",
            "probably overthinking",
            "classic me",
            "tomorrow will be different",
            "or maybe not",
            "at least i tried",
            "universe has plans i guess"
        ]
        
        let surrealistFragments = [
            "my {object} would understand",
            "reality is optional anyway",
            "physics is more like guidelines",
            "time is fake",
            "nothing surprises me anymore",
            "tuesday energy is strong today"
        ]
        
        if realityLevel < 0.4 {
            if let fragment = surrealistFragments.randomElement() {
                return replaceVariables(in: fragment)
            }
        }
        
        return shortFragments.randomElement() ?? "anyway"
    }
    
    private func replaceVariables(in text: String) -> String {
        var result = text
        for (key, values) in templateVariables {
            let placeholder = "{\(key)}"
            if result.contains(placeholder),
               let randomValue = values.randomElement() {
                result = result.replacingOccurrences(of: placeholder, with: randomValue)
            }
        }
        return result
    }
    
    private func generateCoreMLEntry(realityLevel: Double = 0.0) async -> String {
        do {
            // Ensure model is loaded
            if !coreMLGenerator.isModelLoaded {
                try await coreMLGenerator.loadModel()
            }
            
            // Create a prompt based on reality level
            let prompt = createPromptForRealityLevel(realityLevel)
            
            // Generate text using Core ML
            let generated = try await coreMLGenerator.generateText(prompt: prompt, maxLength: 150)
            
            return generated
            
        } catch {
            print("Core ML generation failed, falling back to templates: \(error)")
            return generateSimpleTemplateEntry(realityLevel: realityLevel)
        }
    }
    
    private func createPromptForRealityLevel(_ realityLevel: Double) -> String {
        return generateProceduralPrompt(realityLevel: realityLevel)
    }
    
    private func generateProceduralPrompt(realityLevel: Double) -> String {
        // Create multi-factor seed for maximum uniqueness
        let seed = createMultiFactorSeed()
        var generator = SeededRandomNumberGenerator(seed: seed)
        
        // Select components based on reality level
        let components = selectPromptComponents(realityLevel: realityLevel, generator: &generator)
        
        // Build the procedural prompt
        return buildPromptFromComponents(components)
    }
    
    private func createMultiFactorSeed() -> Int {
        let now = Date()
        let calendar = Calendar.current
        
        // Date factors (changes daily)
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        let dateSeed = (dateComponents.year! % 100) * 10000 + dateComponents.month! * 100 + dateComponents.day!
        
        // Device-specific factors (user uniqueness)
        let deviceSeed = abs(UIDevice.current.identifierForVendor?.uuidString.hashValue ?? 12345) % 10000
        
        // App launch count (grows over time, adds user behavior entropy)
        let launchCountSeed = getAndIncrementLaunchCount() % 10000
        
        // Battery level (changes frequently, always available)
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel >= 0 ? UIDevice.current.batteryLevel : 0.5 // Fallback if unknown
        let batterySeed = Int(batteryLevel * 1000) // Convert 0.0-1.0 to 0-1000
        
        // Combine 4 optimal factors with prime number mixing for excellent distribution
        return (dateSeed * 31 + deviceSeed * 17 + launchCountSeed * 13 + batterySeed * 7) % Int.max
    }
    
    private func getAndIncrementLaunchCount() -> Int {
        let key = "GaslightAppLaunchCount"
        let currentCount = UserDefaults.standard.integer(forKey: key)
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: key)
        return newCount
    }
    
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
    
    // MARK: - Component Pools
    
    private func getCharacterPool(realityLevel: Double) -> [String] {
        let base = ["coffee mug", "houseplant", "favorite pen", "smartphone", "reflection", "shadow", "bookshelf", "alarm clock"]
        let fantastical = ["tiny dragon", "house brownie", "talking bird", "wise spider", "helpful ghost", "library fairy"]
        let whimsical = ["old journal", "reading glasses", "tea kettle", "desk lamp", "favorite sweater", "kitchen timer"]
        
        if realityLevel < 0.3 {
            return base + fantastical + fantastical // Weight toward fantastical
        } else if realityLevel < 0.6 {
            return base + fantastical + whimsical
        } else {
            return base + whimsical + whimsical // Weight toward whimsical
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
}

// MARK: - Supporting Structures

struct PromptComponents {
    let character: String
    let setting: String
    let action: String
    let discovery: String
    let starter: String
    let mood: String
}

// Seeded random number generator for reproducible randomness
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

// MARK: - Extension for AIEntryGenerator
extension AIEntryGenerator {
    func enhanceUserEntry(_ originalText: String, realityLevel: Double) async -> String {
        switch generationMode {
        case .templates:
            return enhanceWithTemplates(originalText, realityLevel: realityLevel)
        case .coreML:
            return await enhanceWithCoreML(originalText, realityLevel: realityLevel)
        case .hybrid:
            return await enhanceWithOnDevice(originalText, realityLevel: realityLevel)
        }
    }
    
    private func enhanceWithOnDevice(_ originalText: String, realityLevel: Double) async -> String {
        do {
            return try await onDeviceGenerator.enhanceUserEntry(originalText, realityLevel: realityLevel)
        } catch {
            print("⚠️ On-device enhancement failed, using templates: \(error)")
            return enhanceWithTemplates(originalText, realityLevel: realityLevel)
        }
    }
    
    private func enhanceWithTemplates(_ originalText: String, realityLevel: Double) -> String {
        // Focus on editing/improving the original text rather than adding content
        var result = originalText
        
        // Step 1: Improve text quality (grammar, punctuation, capitalization)
        result = improveTextQuality(result)
        
        // Step 2: Add minimal stylistic improvements based on reality level
        if realityLevel < 0.3 {
            // Very low reality: Add slight surreal touches to existing content
            result = addSurrealEdits(to: result)
        } else if realityLevel < 0.7 {
            // Medium reality: Add casual, authentic language improvements  
            result = addCasualEdits(to: result)
        } else {
            // High reality: Keep it very close to original, just fix grammar/style
            // Already handled by improveTextQuality above
        }
        
        return result
    }
    
    // MARK: - Minimal Editing Functions
    
    private func addSurrealEdits(to text: String) -> String {
        // Add subtle surreal touches while keeping the original meaning
        var result = text
        
        // Occasionally replace mundane words with slightly more interesting ones
        let surrealReplacements: [String: String] = [
            " went to ": " wandered to ",
            " walked ": " drifted ",
            " said ": " mentioned ",
            " felt ": " sensed ",
            " thought ": " wondered "
        ]
        
        for (original, replacement) in surrealReplacements {
            if result.contains(original) && Double.random(in: 0...1) < 0.3 {
                result = result.replacingOccurrences(of: original, with: replacement)
                break // Only make one replacement to keep it subtle
            }
        }
        
        return result
    }
    
    private func addCasualEdits(to text: String) -> String {
        // Add casual, authentic touches while preserving meaning
        var result = text
        
        // Only make subtle changes occasionally
        if Double.random(in: 0...1) < 0.2 {
            if result.contains(" very ") {
                result = result.replacingOccurrences(of: " very ", with: " pretty ", options: [], range: nil)
            }
        }
        
        return result
    }
    
    private func enhanceWithCoreML(_ originalText: String, realityLevel: Double) async -> String {
        do {
            if !coreMLGenerator.isModelLoaded {
                try await coreMLGenerator.loadModel()
            }
            
            let prompt = "Enhance this journal entry: \(originalText)"
            return try await coreMLGenerator.generateText(prompt: prompt, maxLength: 150)
        } catch {
            print("Core ML enhancement failed, falling back to templates: \(error)")
            return enhanceWithTemplates(originalText, realityLevel: realityLevel)
        }
    }
    
    func generateContinuation(for existingText: String, realityLevel: Double) async -> String {
        switch generationMode {
        case .templates:
            return generateTemplateContinuation(existingText, realityLevel: realityLevel)
        case .coreML:
            return await generateCoreMLContinuation(existingText, realityLevel: realityLevel)
        case .hybrid:
            return await generateOnDeviceContinuation(existingText, realityLevel: realityLevel)
        }
    }
    
    private func generateOnDeviceContinuation(_ existingText: String, realityLevel: Double) async -> String {
        do {
            return try await onDeviceGenerator.continueEntry(existingText, realityLevel: realityLevel)
        } catch {
            print("⚠️ On-device continuation failed, using templates: \(error)")
            return generateTemplateContinuation(existingText, realityLevel: realityLevel)
        }
    }
    
    private func generateCoreMLContinuation(_ existingText: String, realityLevel: Double) async -> String {
        do {
            if !coreMLGenerator.isModelLoaded {
                try await coreMLGenerator.loadModel()
            }
            
            return try await coreMLGenerator.generateText(prompt: existingText, maxLength: 100)
        } catch {
            print("Core ML continuation failed, falling back to templates: \(error)")
            return generateTemplateContinuation(existingText, realityLevel: realityLevel)
        }
    }
    
    private func generateTemplateContinuation(_ existingText: String, realityLevel: Double) -> String {
        // Generate authentic continuation
        let realisticContinuations = [
            "later i realized",
            "also forgot to mention",
            "update on this situation",
            "so anyway this led to",
            "been thinking about this more",
            "spoke to {person} about it",
            "turns out",
            "plot twist"
        ]
        
        let surrealistContinuations = [
            "my {object} had thoughts about this",
            "reality update",
            "physics called",
            "the universe responded by",
            "time folded and",
            "meanwhile in a parallel dimension"
        ]
        
        let continuation = realityLevel < 0.4 ? 
            surrealistContinuations.randomElement() : 
            realisticContinuations.randomElement()
        
        guard let starter = continuation else {
            return "also things happened"
        }
        
        let continuationContent: String
        if realityLevel < 0.4 {
            // Surreal continuation
            let surrealistContent = [
                "{impossible_thing} which {reality_assessment}",
                "{inanimate_thing} finally admitted {deep_topic}",
                "everything makes sense now that {philosophical_realization}"
            ]
            continuationContent = surrealistContent.randomElement() ?? "reality broke again"
        } else {
            // Realistic continuation  
            let realisticContent = [
                "{person} {social_interaction} about {mundane_complaint}",
                "ended up {simple_task} and {minor_failure}",
                "{emotional_reaction} and {coping_mechanism}",
                "now {procrastinated_task} because {excuse}"
            ]
            continuationContent = realisticContent.randomElement() ?? "life happened"
        }
        
        var result = starter + " " + continuationContent
        result = replaceVariables(in: result)
        result = addAuthenticTouches(to: result, realityLevel: realityLevel)
        result = improveTextQuality(result)
        
        return result
    }
    
    // MARK: - Helper Methods
    
    private func createContextualPrompt(realityLevel: Double) -> String {
        let prompts: [String]
        
        if realityLevel < 0.3 {
            prompts = [
                "Today something impossible happened",
                "Reality felt optional today",
                "I had a philosophical conversation with",
                "Time and space decided to collaborate on"
            ]
        } else if realityLevel < 0.7 {
            prompts = [
                "Something interesting happened today",
                "I noticed something about",
                "There was this moment when",
                "I've been thinking about"
            ]
        } else {
            prompts = [
                "Work was",
                "I went to",
                "Today I had to",
                "Spent time"
            ]
        }
        
        return prompts.randomElement() ?? "Today"
    }
    
    private func generateEnhancedTemplateEntry(realityLevel: Double) -> String {
        // Use the enhanced template generator directly
        let enhancedGenerator = EnhancedTemplateGenerator()
        
        let context = GenerationContext(
            prompt: createContextualPrompt(realityLevel: realityLevel),
            style: realityLevel < 0.3 ? .surreal : (realityLevel < 0.7 ? .creative : .realistic),
            tone: .casual,
            maxLength: 200,
            temperature: 0.7,
            realityLevel: realityLevel
        )
        
        // Since we're already on MainActor, we can call async function directly
        Task {
            return await enhancedGenerator.generateText(context: context)
        }
        
        // For now, return synchronous fallback
        let template = generateTemplateEntry(realityLevel: realityLevel)
        return improveTextQuality(template)
    }
    
    private func improveTextQuality(_ text: String) -> String {
        var improved = text
        
        // Fix capitalization
        improved = capitalizeFirstLetters(improved)
        
        // Fix spacing
        improved = fixSpacing(improved)
        
        // Fix contractions
        improved = fixContractions(improved)
        
        // Fix punctuation
        improved = fixPunctuation(improved)
        
        return improved
    }
    
    private func capitalizeFirstLetters(_ text: String) -> String {
        guard !text.isEmpty else { return text }
        
        // First capitalize the very beginning of the text
        let result = text.prefix(1).uppercased() + text.dropFirst()
        
        // Then handle sentence capitalization after periods
        let sentences = result.components(separatedBy: ". ")
        let capitalized = sentences.enumerated().map { index, sentence in
            guard !sentence.isEmpty else { return sentence }
            // Skip first sentence since we already capitalized it
            if index == 0 {
                return sentence
            }
            return sentence.prefix(1).uppercased() + sentence.dropFirst()
        }
        return capitalized.joined(separator: ". ")
    }
    
    private func fixSpacing(_ text: String) -> String {
        var fixed = text
        
        // Fix missing spaces after punctuation
        fixed = fixed.replacingOccurrences(of: ".", with: ". ")
        fixed = fixed.replacingOccurrences(of: ",", with: ", ")
        fixed = fixed.replacingOccurrences(of: "!", with: "! ")
        fixed = fixed.replacingOccurrences(of: "?", with: "? ")
        
        // Remove duplicate spaces
        while fixed.contains("  ") {
            fixed = fixed.replacingOccurrences(of: "  ", with: " ")
        }
        
        return fixed.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func fixContractions(_ text: String) -> String {
        let contractions: [String: String] = [
            "dont": "don't", "cant": "can't", "wont": "won't",
            "couldnt": "couldn't", "shouldnt": "shouldn't", "wouldnt": "wouldn't",
            "isnt": "isn't", "arent": "aren't", "wasnt": "wasn't", "werent": "weren't",
            "hasnt": "hasn't", "havent": "haven't", "hadnt": "hadn't",
            "thats": "that's", "whats": "what's", "heres": "here's",
            "theres": "there's", "wheres": "where's",
            "Im": "I'm", "youre": "you're", "theyre": "they're"
        ]
        
        var fixed = text
        for (incorrect, correct) in contractions {
            let pattern = "\\b\(incorrect)\\b"
            fixed = fixed.replacingOccurrences(of: pattern, with: correct, options: [.regularExpression, .caseInsensitive])
        }
        
        return fixed
    }
    
    private func fixPunctuation(_ text: String) -> String {
        var fixed = text
        
        // Ensure sentences end with proper punctuation
        if !fixed.isEmpty && ![".", "!", "?"].contains(String(fixed.last!)) {
            fixed += "."
        }
        
        return fixed
    }
    
    // MARK: - Template Generation (Fallback)
    
    private func generateSimpleTemplateEntry(realityLevel: Double) -> String {
        let seed = createMultiFactorSeed()
        var generator = SeededRandomNumberGenerator(seed: seed)
        let components = selectPromptComponents(realityLevel: realityLevel, generator: &generator)
        
        // Create a simple journal entry from components
        let templates = [
            "Today I discovered that my \(components.character) has been \(components.action). \(components.discovery)",
            "\(components.starter) my \(components.character) started \(components.action) in the \(components.setting).",
            "I had the most \(components.mood) experience with my \(components.character) today. Turns out it's been \(components.action) all along!",
            "Something magical happened: I found out my \(components.character) has been secretly \(components.action). \(components.discovery)"
        ]
        
        let template = templates.randomElement(using: &generator) ?? templates[0]
        return improveTextQuality(template)
    }
    
}

// MARK: - Future: Core ML Integration
extension AIEntryGenerator {
    // TODO: Implement Core ML text generation
    // This is where we'd integrate a local language model
    
    private func generateWithCoreML(prompt: String) async -> String? {
        // Future implementation with Core ML
        return nil
    }
}