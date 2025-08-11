//
//  EnhancedTemplateGenerator.swift
//  Gaslight
//
//  Created by Albert Xu on 8/6/25.
//

import Foundation

// Enhanced template system for basic tier devices with improved text quality
class EnhancedTemplateGenerator {
    
    func generateText(context: GenerationContext) async -> String {
        // Simulate brief processing for consistency
        try? await Task.sleep(for: .milliseconds(500))
        
        return generateEnhancedTemplate(context: context)
    }
    
    private func generateEnhancedTemplate(context: GenerationContext) -> String {
        switch context.style {
        case .realistic:
            return generateRealisticTemplate(context: context)
        case .creative:
            return generateCreativeTemplate(context: context)
        case .surreal:
            return generateSurrealTemplate(context: context)
        }
    }
    
    private func generateRealisticTemplate(context: GenerationContext) -> String {
        let realisticPatterns = [
            "Work was {work_feeling} today. {colleague_situation} and {work_outcome}. {reflection_on_work}",
            
            "Couldn't sleep well last night. {sleep_issue} kept me up, so I {late_night_activity}. {tired_feeling} this morning.",
            
            "Had coffee with {person} today. We talked about {conversation_topic} and {social_outcome}. {social_reflection}",
            
            "Tried to {daily_task} but {minor_obstacle} happened. {coping_response} and {task_resolution}.",
            
            "The weather was {weather_type} so I {weather_activity}. {weather_mood_connection} and {day_reflection}."
        ]
        
        let variables: [String: [String]] = [
            "work_feeling": ["actually productive", "pretty overwhelming", "surprisingly smooth", "frustratingly slow"],
            "colleague_situation": ["Mike was being extra helpful", "the new person asked good questions", "everyone seemed stressed about the deadline", "the meeting ran longer than expected"],
            "work_outcome": ["got more done than I thought I would", "realized I need better organization", "felt genuinely satisfied with my progress", "decided tomorrow needs better planning"],
            "reflection_on_work": ["It's nice when things click into place.", "I'm learning to manage my energy better.", "Sometimes productivity surprises you.", "Balance is harder than it looks."],
            
            "sleep_issue": ["my neighbor's music", "overthinking about tomorrow", "too much coffee earlier", "stress about the week ahead"],
            "late_night_activity": ["read for a while", "did some light stretching", "organized my thoughts", "listened to calming music"],
            "tired_feeling": ["Dragging a bit", "Surprisingly alert despite", "Really feeling it", "Managing okay"],
            
            "person": ["Sarah", "my roommate", "an old friend", "my sister"],
            "conversation_topic": ["work frustrations", "future plans", "random childhood memories", "current events"],
            "social_outcome": ["both laughed more than expected", "felt really heard", "realized we're in similar places", "left feeling energized"],
            "social_reflection": ["These connections matter more than I remember.", "Good conversations are underrated.", "It's nice to feel understood.", "Human connection is essential."],
            
            "daily_task": ["organize my desk", "meal prep for the week", "call the dentist", "clean out my closet"],
            "minor_obstacle": ["got distracted by other things", "realized it was more complex", "couldn't find what I needed", "ran out of time"],
            "coping_response": ["took a step back", "decided to break it into smaller parts", "asked for help", "set a timer and focused"],
            "task_resolution": ["felt better about making some progress", "accomplished what I could", "made meaningful progress", "took a productive step forward"],
            
            "weather_type": ["surprisingly nice", "gray and moody", "perfectly crisp", "unexpectedly warm"],
            "weather_activity": ["went for a walk", "opened all the windows", "spent time outside", "adjusted my clothing choices"],
            "weather_mood_connection": ["matched my mood perfectly", "lifted my spirits", "made me feel contemplative", "energized me"],
            "day_reflection": ["sometimes small pleasures matter most", "I should pay attention to these details more", "weather affects me more than I realize", "grateful for these simple moments"]
        ]
        
        let pattern = realisticPatterns.randomElement() ?? "Today was a day of small experiences and quiet understanding."
        return replaceVariablesInText(pattern, with: variables)
    }
    
    private func generateCreativeTemplate(context: GenerationContext) -> String {
        let creativePatterns = [
            "Today felt like {creative_metaphor}. {creative_observation} and {creative_realization}. {philosophical_ending}",
            
            "I noticed {sensory_detail} while {routine_activity}, and it reminded me of {memory_connection}. {creative_insight}",
            
            "There's something {abstract_quality} about {mundane_situation}. {poetic_observation} {meaningful_conclusion}"
        ]
        
        let variables: [String: [String]] = [
            "creative_metaphor": ["a chapter I'm still writing", "a song I recognize but can't name", "a conversation with possibility", "a question disguised as an ordinary Tuesday"],
            "creative_observation": ["The light hit everything differently", "Time moved like honey", "Colors seemed more intentional", "Sounds had texture I hadn't noticed"],
            "creative_realization": ["I realized I was exactly where I needed to be", "the ordinary revealed its hidden poetry", "meaning emerged from the mundane", "I felt connected to something larger"],
            "philosophical_ending": ["Maybe awareness is the real adventure.", "Beauty lives in the details we usually miss.", "These moments of clarity are gifts.", "Life keeps teaching if we keep listening."],
            
            "sensory_detail": ["how the morning light filtered through the window", "the specific sound of rain on different surfaces", "the way coffee steam creates temporary art", "how silence has its own presence"],
            "routine_activity": ["making breakfast", "walking to work", "checking email", "getting dressed"],
            "memory_connection": ["childhood mornings", "a conversation from years ago", "the feeling of possibility", "moments of perfect understanding"],
            "creative_insight": ["Sometimes the past and present have conversations we're not meant to overhear, just witness.", "Memory and reality dance together in ways that feel both strange and natural.", "There's poetry in the space between remembering and experiencing."],
            
            "abstract_quality": ["almost musical", "quietly profound", "gently mysterious", "beautifully complex"],
            "mundane_situation": ["waiting for the bus", "doing dishes", "organizing paperwork", "choosing what to wear"],
            "poetic_observation": ["It's like life whispers its secrets through the most ordinary moments.", "The universe has conversations with us through the details we almost miss.", "There's a hidden narrative running through everything."],
            "meaningful_conclusion": ["I'm learning to listen to these subtle stories."]
        ]
        
        let pattern = creativePatterns.randomElement() ?? "Today offered quiet revelations disguised as ordinary moments."
        return replaceVariablesInText(pattern, with: variables)
    }
    
    private func generateSurrealTemplate(context: GenerationContext) -> String {
        let surrealPatterns = [
            "My {household_object} {surreal_behavior} today, which {reality_assessment}. {universe_response} {philosophical_absurdity}",
            
            "I discovered that {impossible_thing} while {normal_activity}. {time_weirdness} and {spatial_confusion}. {absurd_wisdom}",
            
            "Had a meaningful conversation with {inanimate_entity} about {deep_topic}. {unexpected_agreement} {reality_conclusion}"
        ]
        
        let variables: [String: [String]] = [
            "household_object": ["coffee mug", "houseplant", "bathroom mirror", "kitchen timer", "desk lamp"],
            "surreal_behavior": ["offered unsolicited life coaching", "started judging my decisions", "developed opinions about my taste in music", "began commenting on my posture"],
            "reality_assessment": ["explains so much about my week", "makes perfect sense in retrospect", "clarifies several ongoing mysteries", "puts everything into perspective"],
            "universe_response": ["The universe nodded approvingly.", "Reality shrugged and kept going.", "Time paused to take notes.", "Physics sent a polite complaint."],
            "philosophical_absurdity": ["Apparently wisdom comes from the strangest places. Who knew Tuesday had so much to teach?", "I'm beginning to suspect that logic is overrated and intuition is having the last laugh.", "Sometimes the most honest conversations happen with the most unlikely participants."],
            
            "impossible_thing": ["gravity forgot how to work properly", "colors started having preferences about objects", "sounds became visible for exactly forty-three seconds", "thoughts began having their own thoughts"],
            "normal_activity": ["brushing my teeth", "making toast", "checking the weather", "looking for my keys"],
            "time_weirdness": ["Minutes moved backwards", "Hours compressed into moments", "Seconds stretched like taffy", "Time folded in on itself"],
            "spatial_confusion": ["directions became suggestions", "distances negotiated with my expectations", "rooms rearranged themselves", "the kitchen migrated closer to the bedroom"],
            "absurd_wisdom": ["I'm learning that reality is more of a rough draft than a final manuscript, and honestly, I prefer it that way."],
            
            "inanimate_entity": ["the houseplant", "my reflection", "the refrigerator", "the ceiling fan"],
            "deep_topic": ["the nature of consciousness", "why Tuesdays feel different from other days", "the philosophy of lost socks", "whether thoughts have weight"],
            "unexpected_agreement": ["We reached a surprising consensus.", "Turns out we had similar perspectives.", "The conversation was more enlightening than expected.", "Found common ground in unexpected places."],
            "reality_conclusion": ["I'm beginning to think that weird is just another word for honest, and honesty is where the real conversations live."]
        ]
        
        let pattern = surrealPatterns.randomElement() ?? "Reality took an intermission today, and I'm not entirely sure it came back, but that's okay because the alternative programming was fascinating."
        return replaceVariablesInText(pattern, with: variables)
    }
    
    private func replaceVariablesInText(_ text: String, with variables: [String: [String]]) -> String {
        var result = text
        
        for (key, values) in variables {
            let placeholder = "{\(key)}"
            if result.contains(placeholder),
               let randomValue = values.randomElement() {
                result = result.replacingOccurrences(of: placeholder, with: randomValue)
            }
        }
        
        // Apply text quality improvements
        return improveTextQuality(result)
    }
    
    private func improveTextQuality(_ text: String) -> String {
        var improved = text
        
        // Fix capitalization - capitalize first letter of sentences
        improved = capitalizeFirstLetters(improved)
        
        // Fix common spacing issues
        improved = fixSpacing(improved)
        
        // Fix common contractions
        improved = fixContractions(improved)
        
        // Ensure proper punctuation
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
        
        return fixed
    }
    
    private func fixContractions(_ text: String) -> String {
        let contractions: [String: String] = [
            "dont": "don't",
            "cant": "can't", 
            "wont": "won't",
            "couldnt": "couldn't",
            "shouldnt": "shouldn't",
            "wouldnt": "wouldn't",
            "isnt": "isn't",
            "arent": "aren't",
            "wasnt": "wasn't",
            "werent": "weren't",
            "hasnt": "hasn't",
            "havent": "haven't",
            "hadnt": "hadn't",
            "thats": "that's",
            "whats": "what's",
            "heres": "here's",
            "theres": "there's",
            "wheres": "where's",
            "its": "it's", // Note: this might create its/it's confusion, but usually "its" in casual writing means "it is"
            "Im": "I'm",
            "youre": "you're",
            "were": "we're", // Context dependent, but often means "we are" in casual writing
            "theyre": "they're"
        ]
        
        var fixed = text
        for (incorrect, correct) in contractions {
            // Replace word boundaries to avoid partial matches
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
}