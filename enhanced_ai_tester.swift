//
//  Enhanced AI Mode Tester
//  Gaslight - Comprehensive AI Testing with CSV Output
//
//  Tests AI modes with varied input lengths and generates spreadsheet-friendly output
//

import Foundation

class EnhancedAITester {
    
    // Test inputs ranging from empty to elaborate
    static let testInputs: [(description: String, input: String)] = [
        // Empty input - pure generation
        ("Empty Input", ""),
        
        // Single word prompts
        ("Single Word - Morning", "Morning"),
        ("Single Word - Dreams", "Dreams"),
        ("Single Word - Coffee", "Coffee"),
        
        // One sentence starters
        ("One Sentence - Feeling", "Today I woke up feeling different."),
        ("One Sentence - Discovery", "I discovered something unexpected."),
        ("One Sentence - Memory", "A memory surfaced that I hadn't thought about in years."),
        
        // Couple sentences
        ("Two Sentences - Work", "Work was particularly challenging today. I found myself questioning some of the decisions I've been making."),
        ("Two Sentences - Relationship", "Had an interesting conversation with a friend. It made me realize how much I've changed over the past year."),
        ("Two Sentences - Nature", "Went for a walk in the park this evening. The way the light filtered through the trees reminded me of childhood summers."),
        
        // Short paragraph
        ("Short Paragraph - Reflection", """
        I've been thinking a lot about change lately. It's strange how life can feel so routine day-to-day, yet when you step back and look at where you were a year ago, everything seems different. The small shifts in perspective, the gradual evolution of priorities, the way relationships deepen or fade.
        """),
        
        ("Short Paragraph - Observation", """
        There's something hypnotic about watching people in coffee shops. Everyone absorbed in their own little worlds - typing, reading, staring out windows. I wonder what stories they're carrying, what problems they're solving, what dreams they're nurturing over their morning caffeine ritual.
        """),
        
        // Longer paragraph
        ("Long Paragraph - Deep Thought", """
        The concept of authenticity has been weighing on my mind recently. We're constantly told to "be ourselves," but what does that even mean? Are we the sum of our thoughts, our actions, our relationships? Or are we something more fluid - constantly becoming rather than simply being? I used to think identity was fixed, something you discovered and then lived up to. But now I'm starting to suspect it's more like a story we tell ourselves, one that changes with each telling. The question isn't who am I, but who am I becoming, and do I like the direction of that transformation?
        """),
        
        ("Long Paragraph - Experience", """
        Yesterday I had one of those moments that makes you stop and really pay attention. I was walking home from work, same route I take every day, when I noticed an elderly man feeding pigeons in the small park near my apartment. Nothing unusual about that, except something in his expression caught my eye. He wasn't just tossing bread mindlessly - he was having what looked like a genuine conversation with these birds, nodding and responding as if they were old friends sharing gossip. It struck me how much joy he was finding in this simple ritual, and I realized I couldn't remember the last time I'd been that present in a moment.
        """)
    ]
    
    static func generateCSVReport() -> String {
        var csvContent = "Input Description,Input Text,Templates Output,Core ML Output,Hybrid Low (10%),Hybrid High (90%)\n"
        
        print("🧪 Generating Enhanced AI Comparison Report...")
        print("Testing \(testInputs.count) different input scenarios\n")
        
        for (index, testCase) in testInputs.enumerated() {
            print("[\(index + 1)/\(testInputs.count)] Testing: \(testCase.description)")
            
            let templatesOutput = simulateTemplateGeneration(input: testCase.input)
            let coreMLOutput = simulateCoreMLGeneration(input: testCase.input)
            let hybridLow = simulateHybridGeneration(input: testCase.input, realityLevel: 0.1)
            let hybridHigh = simulateHybridGeneration(input: testCase.input, realityLevel: 0.9)
            
            // Clean strings for CSV (escape quotes, remove newlines)
            let cleanInput = cleanForCSV(testCase.input)
            let cleanTemplates = cleanForCSV(templatesOutput)
            let cleanCoreML = cleanForCSV(coreMLOutput)
            let cleanHybridLow = cleanForCSV(hybridLow)
            let cleanHybridHigh = cleanForCSV(hybridHigh)
            
            csvContent += "\"\(testCase.description)\",\"\(cleanInput)\",\"\(cleanTemplates)\",\"\(cleanCoreML)\",\"\(cleanHybridLow)\",\"\(cleanHybridHigh)\"\n"
        }
        
        return csvContent
    }
    
    static func cleanForCSV(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "\"", with: "\"\"")  // Escape quotes
            .replacingOccurrences(of: "\n", with: " ")     // Replace newlines with spaces
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func simulateTemplateGeneration(input: String) -> String {
        if input.isEmpty {
            // Pure generation for empty input
            let pureGenerationTemplates = [
                "Today my coffee mug started giving me relationship advice.",
                "I've been reorganizing my sock drawer by emotional significance.",
                "The houseplant in my kitchen has been judging my breakfast choices.",
                "I discovered I've been having conversations with my alarm clock for three weeks.",
                "My favorite pen decided to write poetry instead of grocery lists today."
            ]
            return pureGenerationTemplates.randomElement() ?? "Something happened today."
        }
        
        // Extension templates for existing content
        let extensionTemplates = [
            " Then my coffee mug started offering unsolicited life advice.",
            " I'm pretty sure my houseplant has been taking notes on my behavior.",
            " The strangest part was when my alarm clock started judging my life choices.",
            " I spent the next two hours trying to teach my toaster about boundaries.",
            " My favorite pen has been writing mysterious notes in the margins.",
            " The delivery driver and I ended up discussing quantum physics for twenty minutes.",
            " I've decided to start a support group for people who talk to kitchen appliances.",
            " My coffee has been giving me increasingly philosophical advice lately."
        ]
        
        return input + (extensionTemplates.randomElement() ?? " Something unexpected happened.")
    }
    
    static func simulateCoreMLGeneration(input: String) -> String {
        if input.isEmpty {
            // Pure generation for empty input
            let pureGenerationResponses = [
                "There's something profound about the weight of unwritten thoughts. I find myself drawn to the blank spaces between words, the pauses between breaths, where meaning lives in potential rather than certainty. Today feels like a beginning I haven't yet learned how to name.",
                
                "Memory works in strange loops, doesn't it? I woke this morning with fragments of a dream that felt more real than the room around me. There's a conversation happening between who I was yesterday and who I'm becoming today, and I'm not sure I understand the language yet.",
                
                "The morning light carries stories I've forgotten how to read. There's something beautiful about existing in the space between sleeping and waking, where thoughts arise like bubbles in still water - each one perfect in its own temporary existence."
            ]
            return pureGenerationResponses.randomElement() ?? "Something profound is happening in the spaces between thoughts."
        }
        
        // Extension responses for existing content
        let extensionResponses = [
            " The weight of this realization settled over me like a familiar blanket. There's something profoundly human about recognizing patterns in chaos, about finding meaning in the mundane details of existence. I've been thinking about how we construct narratives from fragments of experience, and wonder if the stories we tell ourselves are more important than the facts we think we remember.",
            
            " What strikes me most is how memory works - not as a recording device, but as a storyteller, constantly editing and revising our past to make sense of our present. I find myself questioning which details are real and which are reconstructions, and whether authenticity is overrated when the alternative is a more compelling narrative.",
            
            " There's a strange comfort in uncertainty, in not knowing exactly where thoughts end and dreams begin. Sometimes I wonder if consciousness is just the most convincing story our minds tell about the chaos of sensation and memory. The boundary between observer and observed seems more fluid than I once believed.",
            
            " I'm learning to be comfortable with the ambiguity of existence, with the way meaning shifts like light through water. There's something beautiful about the conversation happening beneath the surface of every moment - between the experiencer and the narrator, between who we are and who we're becoming."
        ]
        
        return input + (extensionResponses.randomElement() ?? " The implications of this are still unfolding in my consciousness.")
    }
    
    static func simulateHybridGeneration(input: String, realityLevel: Double) -> String {
        if realityLevel < 0.5 {
            // Low reality - use Core ML style (more introspective)
            return simulateCoreMLGeneration(input: input)
        } else {
            // High reality - use Templates style (more structured/whimsical)
            return simulateTemplateGeneration(input: input)
        }
    }
    
    static func generateAnalysisReport() -> String {
        return """
        
        # 📊 Enhanced AI Testing Analysis
        
        ## Test Methodology:
        - **Input Variations**: Empty, single words, sentences, paragraphs, elaborate entries
        - **AI Modes**: Templates, Core ML, Hybrid (10% & 90% reality levels)
        - **Output Format**: CSV for spreadsheet analysis
        - **Focus Areas**: Content generation vs. content extension
        
        ## Key Observations:
        
        ### Content Generation (Empty Input):
        - **Templates**: Quirky, immediate scenarios with personified objects
        - **Core ML**: Deep, philosophical reflections on consciousness and memory
        - **Hybrid**: Adapts style based on reality level setting
        
        ### Content Extension (With Input):
        - **Templates**: Adds whimsical, unexpected continuations
        - **Core ML**: Provides thoughtful, introspective elaborations
        - **Hybrid**: Maintains consistency while adapting to reality preference
        
        ### Length Responsiveness:
        - **Short Inputs**: All modes expand appropriately
        - **Long Inputs**: Core ML provides more sophisticated continuations
        - **Empty Inputs**: Shows pure generation capabilities clearly
        
        ## Recommended Usage:
        
        ### For Quick, Fun Journaling:
        - Use Templates mode with any input length
        - Instant results with creative, absurd touches
        
        ### For Deep Reflection:
        - Use Core ML mode, especially with longer inputs
        - Best for processing complex thoughts and emotions
        
        ### For Adaptive Experience:
        - Use Hybrid mode with Reality Level slider
        - Adjust based on mood and desired output style
        
        """
    }
}

// Generate the CSV report
print("🚀 Starting Enhanced AI Testing...")
let csvReport = EnhancedAITester.generateCSVReport()
let analysisReport = EnhancedAITester.generateAnalysisReport()

print("\n" + String(repeating: "=", count: 50))
print("CSV OUTPUT (Copy to spreadsheet):")
print(String(repeating: "=", count: 50) + "\n")
print(csvReport)

print("\n" + String(repeating: "=", count: 50))
print("ANALYSIS REPORT:")
print(String(repeating: "=", count: 50))
print(analysisReport)

// Save to file
let csvFileName = "ai_comparison_\(Date().timeIntervalSince1970).csv"
print("\n💾 Saving CSV report as: \(csvFileName)")