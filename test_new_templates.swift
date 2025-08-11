#!/usr/bin/env swift

import Foundation

// Simulated version of the new template system for testing
struct TemplateGenerator {
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
    
    func generateEntry(realityLevel: Double) -> String {
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
        
        // Add authentic touches
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
}

// Generate test entries
let generator = TemplateGenerator()

print("# NEW AUTHENTIC JOURNAL TEMPLATES - TEST RESULTS")
print("Generated on: \(Date())")
print("\n" + String(repeating: "=", count: 80) + "\n")

print("## HIGH REALITY ENTRIES (0.8-0.9) - Realistic Daily Life")
print(String(repeating: "-", count: 60))
for i in 1...8 {
    let entry = generator.generateEntry(realityLevel: Double.random(in: 0.8...0.9))
    print("\(i). \(entry)")
    print()
}

print("\n" + String(repeating: "=", count: 80) + "\n")

print("## MEDIUM REALITY ENTRIES (0.4-0.6) - Mixed")
print(String(repeating: "-", count: 60))
for i in 1...8 {
    let entry = generator.generateEntry(realityLevel: Double.random(in: 0.4...0.6))
    print("\(i). \(entry)")
    print()
}

print("\n" + String(repeating: "=", count: 80) + "\n")

print("## LOW REALITY ENTRIES (0.1-0.3) - Surrealist but Conversational")
print(String(repeating: "-", count: 60))
for i in 1...8 {
    let entry = generator.generateEntry(realityLevel: Double.random(in: 0.1...0.3))
    print("\(i). \(entry)")
    print()
}

print("\n" + String(repeating: "=", count: 80) + "\n")
print("## EVALUATION CRITERIA")
print("""
OLD TEMPLATES (Before):
- "Today my coffee mug started giving me relationship advice. I'm not sure how to feel about this development."
- Very grammatically correct, formal
- Objects doing impossible things
- Overly philosophical

NEW TEMPLATES (Above):
✓ Lowercase, casual language
✓ Real daily struggles (commute, work, family calls)
✓ Authentic emotional reactions
✓ Fragment-based structure
✓ Stream-of-consciousness feel
✓ Actual journaling voice

Compare these to real journal entries - do they feel more human and relatable?
""")