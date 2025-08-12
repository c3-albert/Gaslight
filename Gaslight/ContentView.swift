//
//  ContentView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var journalText: String = ""
    @State private var originalText: String = ""
    @State private var userOriginalText: String = "" // Preserves the actual user input
    @State private var realityLevel: Double = 1.0
    @State private var showSavedMessage: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false
    @StateObject private var typewriterViewModel = TypewriterViewModel()
    @StateObject private var groqGenerator = GroqAIGenerator.shared
    @State private var isGeneratingAI: Bool = false

    private var isWritingForDifferentDate: Bool {
        !Calendar.current.isDate(selectedDate, inSameDayAs: Date())
    }
    
    private var dateDisplayText: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else if Calendar.current.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: selectedDate)
        }
    }

    var body: some View {
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                // Date picker section
                HStack {
                    Text("Writing for:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showDatePicker.toggle() }) {
                        HStack {
                            Text(dateDisplayText)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(isWritingForDifferentDate ? .orange : .primary)
                            
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isWritingForDifferentDate ? Color.orange.opacity(0.1) : Color(.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isWritingForDifferentDate ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                    
                    if isWritingForDifferentDate {
                        Button("Reset to Today") {
                            selectedDate = Date()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                
                Text("What's on your mind?")
                    .font(.title2)
                    .fontWeight(.semibold)

                ZStack {
                    TextEditor(text: $journalText)
                        .frame(height: 300)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .onChange(of: journalText) { _, newValue in
                            if !isGeneratingAI {
                                originalText = newValue
                                userOriginalText = newValue // Always preserve the user's actual input
                            }
                        }
                        .disabled(isGeneratingAI)
                        .opacity(isGeneratingAI ? 0.7 : 1.0)
                    
                    // Typewriter overlay when AI is generating
                    if isGeneratingAI {
                        VStack {
                            HStack {
                                Spacer()
                            }
                            Spacer()
                        }
                        .frame(height: 300)
                        .overlay(
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(typewriterViewModel.displayedText)
                                        .font(.system(.body))
                                        .padding()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .background(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange.opacity(0.6), lineWidth: 2)
                            )
                        )
                    }
                }

                // Gaslight Controls
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Reality Level")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(realityLevel * 100))% Real")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("AI")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        ZStack {
                            // Gradient background
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.orange, .blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 6)
                            
                            // Slider on top
                            Slider(value: $realityLevel, in: 0...1, step: 0.1)
                                .accentColor(.white)
                                .onChange(of: realityLevel) { _, newValue in
                                    // Add haptic feedback at key thresholds
                                    let thresholds: [Double] = [0.0, 0.25, 0.5, 0.75, 1.0]
                                    let tolerance = 0.05
                                    
                                    for threshold in thresholds {
                                        if abs(newValue - threshold) < tolerance {
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                            break
                                        }
                                    }
                                }
                        }
                        
                        Text("Real")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: writeForMe) {
                        HStack {
                            if isGeneratingAI {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isGeneratingAI ? "AI Writing..." : "Write for Me")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(userOriginalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGeneratingAI)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                Button(action: saveEntry) {
                    Text("Save Entry")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if showSavedMessage {
                    Text("✅ Entry saved!")
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
                }
                .padding()
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 20)
                }
                
                // Orange AI takeover overlay
                if isGeneratingAI {
                    Color.orange.opacity(0.15)
                        .ignoresSafeArea(.all)
                        .animation(.easeInOut(duration: 0.5), value: isGeneratingAI)
                        .allowsHitTesting(false)
                }
            }
            .sheet(isPresented: $showDatePicker) {
                NavigationView {
                    VStack(spacing: 20) {
                        Text("Choose Date & Time")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                        
                        DatePicker(
                            "Entry Date",
                            selection: $selectedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.wheel)
                        .padding()
                        
                        Spacer()
                    }
                    .navigationTitle("Entry Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showDatePicker = false
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showDatePicker = false
                            }
                            .fontWeight(.semibold)
                        }
                    }
                }
            }
    }
    
    private func saveEntry() {
        guard !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let entryType: EntryType = .userWritten // All entries from ContentView are now user-written
        let content = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
        let original: String? = nil
        
        let newEntry = JournalEntry(
            content: content,
            entryType: entryType,
            realityLevel: realityLevel,
            originalContent: original,
            createdDate: selectedDate
        )
        
        modelContext.insert(newEntry)
        
        do {
            try modelContext.save()
            showSavedMessage = true
            
            
            // Reset form
            journalText = ""
            originalText = ""
            userOriginalText = ""
            realityLevel = 1.0
            selectedDate = Date() // Reset to current date/time
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSavedMessage = false
            }
        } catch {
            print("Failed to save entry: \(error)")
        }
    }
    
    private func writeForMe() {
        Task {
            await MainActor.run {
                isGeneratingAI = true
                typewriterViewModel.displayedText = journalText
            }
            
            do {
                // Create a prompt for continuation based on existing text
                let prompt = userOriginalText.isEmpty ? 
                    "Write a journal entry about your day, thoughts, or experiences." :
                    "Continue this journal entry: \(userOriginalText)"
                
                let additionalText = try await groqGenerator.generateJournalEntry(
                    prompt: prompt,
                    recentEntries: [],
                    realityLevel: realityLevel,
                    theme: nil
                )
                
                // Prepare the full text for typewriter
                let fullText = journalText.isEmpty ? additionalText : journalText + "\n\n" + additionalText
                
                // Start typewriter animation from current text
                await typewriterViewModel.typeText(fullText, speed: 0.03)
                
                await MainActor.run {
                    journalText = fullText
                    originalText = fullText
                    isGeneratingAI = false
                }
            } catch {
                await MainActor.run {
                    isGeneratingAI = false
                    // You might want to show an error message to the user here
                    print("❌ AI generation failed: \(error)")
                }
            }
        }
    }
}
