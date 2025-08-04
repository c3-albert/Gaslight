//
//  AIEntryGenerator.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import Foundation

class AIEntryGenerator {
    static let shared = AIEntryGenerator()
    
    private init() {}
    
    // MARK: - Template-based Generation (Phase 1)
    
    private let entryTemplates = [
        "Today my {object} started {action}. I'm not sure how to feel about this development. It's been {emotion} watching this unfold.",
        "Had a long conversation with my {object} about {topic}. Surprisingly insightful perspectives on {philosophical_concept}.",
        "Discovered that I've been {weird_action} for the past {time_period}. My {person} thinks this explains {random_conclusion}.",
        "The {object} in my {location} has been giving me life advice. Today's wisdom: {advice}.",
        "Spent {time_period} trying to {impossible_task}. Made surprising progress, though I'm questioning my methods.",
        "My {object} and I had a disagreement about {trivial_topic}. We're not speaking right now.",
        "Woke up to find I had apparently {weird_action} in my sleep. There's evidence everywhere.",
        "Today I learned that my {skill_level} in {random_skill} is actually quite {surprising_result}.",
        "The {weather} reminded me of {random_memory} from when I was {age}. Decided to {spontaneous_action}.",
        "Had an epiphany while {mundane_activity}: {profound_realization}. Changed my entire perspective on {life_aspect}."
    ]
    
    private let templateVariables: [String: [String]] = [
        "object": ["coffee mug", "houseplant", "toaster", "favorite pen", "pillow", "alarm clock", "mirror", "doorknob", "phone charger", "lamp"],
        "action": ["giving me relationship advice", "judging my life choices", "speaking French", "writing poetry", "doing yoga", "planning my schedule", "composing music", "offering cooking tips"],
        "emotion": ["bewildering", "oddly comforting", "mildly concerning", "surprisingly enlightening", "absolutely fascinating", "deeply confusing"],
        "topic": ["quantum physics", "the meaning of existence", "why socks disappear", "optimal pizza toppings", "the nature of time", "whether cats are plotting something"],
        "philosophical_concept": ["free will", "the butterfly effect", "why we procrastinate", "the perfect morning routine", "social media addiction"],
        "weird_action": ["reorganizing my spice rack alphabetically", "having full conversations with delivery drivers", "collecting bottle caps", "practicing acceptance speeches", "naming all the pigeons in my neighborhood"],
        "time_period": ["three weeks", "two months", "six hours", "the entire morning", "twenty-seven minutes", "half my life"],
        "person": ["neighbor", "barista", "delivery person", "dentist", "mom", "coworker", "Uber driver"],
        "random_conclusion": ["my recent streak of losing keys", "why I keep buying plants I can't keep alive", "my inexplicable fear of butterflies", "why I always choose the slowest checkout line"],
        "location": ["kitchen", "bedroom", "bathroom", "living room", "office", "car", "hallway"],
        "advice": ["Stop overthinking your lunch choices", "Embrace the chaos of mismatched socks", "Dance like nobody's judging your playlist", "Your potential is showing", "Sometimes the answer is more coffee"],
        "impossible_task": ["teach my cat about boundaries", "organize my digital photos", "remember where I put my keys", "understand why anyone likes small talk", "achieve inbox zero"],
        "trivial_topic": ["the correct way to load a dishwasher", "whether cereal is soup", "optimal sleeping positions", "the ethics of skipping introductions on podcasts"],
        "weather": ["rain", "unexpected sunshine", "perfectly average Tuesday morning", "mysterious fog", "unusually specific breeze"],
        "random_memory": ["trying to convince adults I was a dinosaur expert", "believing escalators were magic", "thinking teachers lived at school", "my theory that clouds were made of cotton candy"],
        "age": ["seven", "twelve", "sixteen", "way too old to think that"],
        "spontaneous_action": ["rearrange my entire bookshelf", "learn three words in a new language", "write a letter to my future self", "reorganize my music playlist"],
        "mundane_activity": ["doing dishes", "folding laundry", "waiting for the elevator", "brushing my teeth", "making coffee"],
        "profound_realization": ["I've been overthinking everything", "happiness is just really good timing", "I should probably call my mom more", "life is just a series of small decisions", "I'm exactly where I need to be"],
        "life_aspect": ["time management", "relationships", "career goals", "what really matters", "the art of doing nothing"],
        "skill_level": ["hidden talent", "complete inability", "natural aptitude", "surprising competence"],
        "random_skill": ["parallel parking", "small talk with strangers", "keeping plants alive", "remembering names", "assembling IKEA furniture"],
        "surprising_result": ["impressive", "concerning", "unexpectedly therapeutic", "secretly my superpower", "absolutely terrible but endearing"]
    ]
    
    func generateEntry(realityLevel: Double = 0.0) -> String {
        // For now, use template-based generation
        // Lower reality level = more absurd
        
        guard let template = entryTemplates.randomElement() else {
            return "Today was a day. Things happened. I was there for most of it."
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
        
        // Add some reality-level based modifications
        if realityLevel < 0.3 {
            // Very unrealistic - add extra absurdity
            let absurdAdditions = [
                " Plot twist: this actually happened twice today.",
                " I'm starting to question everything I thought I knew.",
                " My therapist is going to have a field day with this one.",
                " I should probably document this for science.",
                " Update: It happened again while I was writing this."
            ]
            
            if let addition = absurdAdditions.randomElement() {
                result += addition
            }
        }
        
        return result
    }
    
    func enhanceUserEntry(_ originalText: String, realityLevel: Double) -> String {
        // Take user's real entry and make it slightly more absurd
        let enhancements = [
            " (At least, that's what I told myself.)",
            " Plot twist: I was completely wrong about all of this.",
            " Future me is probably laughing at this entry.",
            " In retrospect, this was clearly a sign.",
            " I should have known it would lead to the great incident of next Tuesday."
        ]
        
        if realityLevel < 0.7, let enhancement = enhancements.randomElement() {
            return originalText + enhancement
        }
        
        return originalText
    }
    
    func generateContinuation(for existingText: String, realityLevel: Double) -> String {
        // Generate additional text that continues from the existing entry
        let continuations = [
            "Later that day, I realized something even more interesting.",
            "This got me thinking about what happened next.",
            "But wait, there's more to this story.",
            "The plot thickened when I discovered something else.",
            "What I didn't mention earlier is that this led to something unexpected.",
            "Looking back, I should have seen the signs of what was coming.",
            "The real adventure began after I thought it was over.",
            "This reminded me of something that happened before.",
            "I forgot to mention the most important part.",
            "The consequences of this are still unfolding."
        ]
        
        guard let starter = continuations.randomElement() else {
            return "And then things got interesting."
        }
        
        // Add some content based on reality level
        let additions = [
            "My {object} started {action} in response to all this.",
            "Turns out my {person} had been experiencing something similar.",
            "I decided to {spontaneous_action} to process everything.",
            "The whole experience gave me {profound_realization}.",
            "I'm pretty sure this explains my recent {random_conclusion}."
        ]
        
        guard let template = additions.randomElement() else {
            return starter
        }
        
        var result = starter + " " + template
        
        // Replace template variables
        for (key, values) in templateVariables {
            let placeholder = "{\(key)}"
            if result.contains(placeholder),
               let randomValue = values.randomElement() {
                result = result.replacingOccurrences(of: placeholder, with: randomValue)
            }
        }
        
        // Add reality-based modifications
        if realityLevel < 0.4 {
            let wildEndings = [
                " I'm still processing what this means for my life philosophy.",
                " My worldview may never recover from this revelation.",
                " I should probably warn others about what I've learned.",
                " This explains so many things I never understood before."
            ]
            
            if let ending = wildEndings.randomElement() {
                result += ending
            }
        }
        
        return result
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