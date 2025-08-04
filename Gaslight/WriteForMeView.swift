//
//  WriteForMeView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI
import SwiftData

struct WriteForMeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let entry: JournalEntry
    @State private var additionalText: String = ""
    @State private var realityLevel: Double = 0.5
    @State private var showSavedMessage = false
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Original entry context
                VStack(alignment: .leading, spacing: 8) {
                    Text("Original entry from:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(entry.formattedDate)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ScrollView {
                        Text(entry.content)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 120)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                // Reality level control
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Reality Level for Additional Text")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(realityLevel * 100))% Real")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("🤖")
                            .font(.caption)
                        Slider(value: $realityLevel, in: 0...1, step: 0.1)
                        Text("✍️")
                            .font(.caption)
                    }
                    
                    Button(action: generateAdditionalText) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                            Text(isGenerating ? "Generating..." : "Generate More Text")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isGenerating)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Generated/edited text
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Text:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $additionalText)
                        .frame(minHeight: 150)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if additionalText.isEmpty {
                                    Text("Generate additional text or write your own...")
                                        .foregroundColor(.secondary)
                                        .padding(16)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .allowsHitTesting(false)
                                }
                            }
                        )
                }
                
                if showSavedMessage {
                    Text("✅ Additional text added to entry!")
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Write for Me")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add to Entry") {
                        appendToEntry()
                    }
                    .fontWeight(.semibold)
                    .disabled(additionalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func generateAdditionalText() {
        isGenerating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let generator = AIEntryGenerator.shared
            let continuation = generator.generateContinuation(for: entry.content, realityLevel: realityLevel)
            additionalText = continuation
            isGenerating = false
        }
    }
    
    private func appendToEntry() {
        let trimmedText = additionalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Append the new text to the existing content
        let newContent = entry.content + "\n\n" + trimmedText
        entry.updateContent(newContent)
        
        // Update entry type to indicate AI enhancement
        if entry.entryType == .userWritten {
            entry.entryType = .aiEnhanced
            if entry.originalContent == nil {
                entry.originalContent = entry.content.replacingOccurrences(of: "\n\n" + trimmedText, with: "")
            }
        }
        
        do {
            try modelContext.save()
            showSavedMessage = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            print("Failed to append text to entry: \(error)")
        }
    }
}