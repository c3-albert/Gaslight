//
//  TypewriterText.swift
//  Gaslight
//
//  Created by Albert Xu on 8/5/25.
//

import SwiftUI

struct TypewriterText: View {
    let fullText: String
    let speed: TimeInterval
    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @Binding var isAnimating: Bool
    
    var onComplete: (() -> Void)?
    
    init(text: String, speed: TimeInterval = 0.05, isAnimating: Binding<Bool>, onComplete: (() -> Void)? = nil) {
        self.fullText = text
        self.speed = speed
        self._isAnimating = isAnimating
        self.onComplete = onComplete
    }
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                startTypewriterAnimation()
            }
            .onChange(of: fullText) { _, newText in
                // Reset animation when text changes
                resetAnimation()
                startTypewriterAnimation()
            }
    }
    
    private func startTypewriterAnimation() {
        guard !fullText.isEmpty else {
            isAnimating = false
            onComplete?()
            return
        }
        
        isAnimating = true
        displayedText = ""
        currentIndex = 0
        
        typeNextCharacter()
    }
    
    private func typeNextCharacter() {
        guard currentIndex < fullText.count else {
            isAnimating = false
            onComplete?()
            return
        }
        
        let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
        displayedText.append(fullText[index])
        currentIndex += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
            typeNextCharacter()
        }
    }
    
    private func resetAnimation() {
        displayedText = ""
        currentIndex = 0
        isAnimating = false
    }
}

// Alternative streaming approach for live text updates
@MainActor
class TypewriterViewModel: ObservableObject {
    @Published var displayedText: String = ""
    @Published var isAnimating: Bool = false
    
    private var animationTask: Task<Void, Never>?
    
    func typeText(_ text: String, speed: TimeInterval = 0.05) async {
        await MainActor.run {
            isAnimating = true
            displayedText = ""
        }
        
        for (_, character) in text.enumerated() {
            await MainActor.run {
                displayedText.append(character)
            }
            
            // Add slight randomness to make it feel more natural
            let variance = speed * 0.3
            let randomDelay = speed + Double.random(in: -variance...variance)
            let delay = max(0.01, randomDelay)
            
            try? await Task.sleep(for: .milliseconds(Int(delay * 1000)))
            
            // Check if task was cancelled
            if Task.isCancelled {
                await MainActor.run {
                    isAnimating = false
                }
                return
            }
        }
        
        await MainActor.run {
            isAnimating = false
        }
    }
    
    func stopAnimation() {
        animationTask?.cancel()
        isAnimating = false
    }
    
    func startStreamingText(_ text: String, speed: TimeInterval = 0.05) {
        stopAnimation()
        animationTask = Task {
            await typeText(text, speed: speed)
        }
    }
}