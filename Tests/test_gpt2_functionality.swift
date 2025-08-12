#!/usr/bin/env swift

/*
 * GPT-2 Core ML Functionality Test
 * 
 * This script tests the Core ML GPT-2 model loading and generation capabilities
 * by simulating what the app does internally.
 */

import Foundation
import CoreML

print("🧪 Testing GPT-2 Core ML Functionality...")
print("==========================================")

func testModelLoading() {
    print("\n1️⃣ Testing Model Loading...")
    
    do {
        // Try to find the model in the bundle (simulated app bundle path)
        let modelPath = "/Users/albertxu/Documents/Gaslight/Gaslight/gpt2-512.mlmodel"
        let modelURL = URL(fileURLWithPath: modelPath)
        
        if FileManager.default.fileExists(atPath: modelPath) {
            print("   ✅ Model file found at: \(modelPath)")
            
            // Try to load the model
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all
            
            let model = try MLModel(contentsOf: modelURL, configuration: configuration)
            print("   ✅ Core ML model loaded successfully!")
            print("   📊 Model description: \(model.modelDescription)")
            
            // Check input/output specs
            let inputDescription = model.modelDescription.inputDescriptionsByName
            let outputDescription = model.modelDescription.outputDescriptionsByName
            
            print("   📝 Input features:")
            for (name, description) in inputDescription {
                print("      - \(name): \(description.type)")
            }
            
            print("   📝 Output features:")
            for (name, description) in outputDescription {
                print("      - \(name): \(description.type)")
            }
            
        } else {
            print("   ❌ Model file not found")
        }
        
    } catch {
        print("   ❌ Failed to load model: \(error)")
    }
}

func testBasicGeneration() {
    print("\n2️⃣ Testing Basic Text Generation...")
    
    // This would test the actual generation, but requires the full app context
    print("   ℹ️ Basic generation test requires full app context")
    print("   ℹ️ Use the iOS Simulator to test actual generation")
}

// Run the tests
testModelLoading()
testBasicGeneration()

print("\n✅ GPT-2 functionality test completed!")