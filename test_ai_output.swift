// Quick test script to verify AI generation modes
// Run this in a Swift playground or as a unit test

import Foundation

// Simulate the different AI generation modes
func testAIGenerationModes() {
    print("=== AI Generation Mode Testing ===\n")
    
    let testPrompt = "Today I discovered something interesting:"
    
    // Template-based generation (original)
    print("🔧 TEMPLATE MODE:")
    let templateResult = simulateTemplateGeneration(prompt: testPrompt)
    print(templateResult)
    print()
    
    // Core ML enhanced generation (current implementation)
    print("🤖 CORE ML MODE:")
    let coreMLResult = simulateCoreMLGeneration(prompt: testPrompt)
    print(coreMLResult)
    print()
    
    // Analysis
    print("📊 ANALYSIS:")
    print("Template length: \(templateResult.count) characters")
    print("Core ML length: \(coreMLResult.count) characters")
    print("Core ML is more verbose: \(coreMLResult.count > templateResult.count)")
    print("Core ML feels more introspective: \(coreMLResult.contains("consciousness") || coreMLResult.contains("reality") || coreMLResult.contains("memory"))")
}

func simulateTemplateGeneration(prompt: String) -> String {
    // Simulate original template system
    let endings = [
        " My coffee mug started giving me relationship advice.",
        " I've been reorganizing my spice rack alphabetically for three weeks.",
        " The toaster has been judging my life choices all morning."
    ]
    return prompt + (endings.randomElement() ?? "")
}

func simulateCoreMLGeneration(prompt: String) -> String {
    // Simulate enhanced Core ML generation
    let thoughtfulContinuations = [
        " The weight of this realization settled over me like a familiar blanket. There's something profoundly human about recognizing patterns in chaos, about finding meaning in the mundane details of existence. I've been thinking about how we construct narratives from fragments of experience.",
        
        " What strikes me most is how memory works - not as a recording device, but as a storyteller, constantly editing and revising our past to make sense of our present. I find myself questioning which details are real and which are reconstructions.",
        
        " There's a strange comfort in uncertainty, in not knowing exactly where thoughts end and dreams begin. Sometimes I wonder if authenticity is overrated - maybe the stories we tell ourselves are more important than the facts we think we remember."
    ]
    return prompt + (thoughtfulContinuations.randomElement() ?? "")
}

// Run the test
testAIGenerationModes()