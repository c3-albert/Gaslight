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
    @State private var realityLevel: Double = 1.0
    @State private var showSavedMessage: Bool = false
    @State private var isGaslighted: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false

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
        NavigationView {
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
                                .fill(Color(.secondarySystemBackground))
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

                TextEditor(text: $journalText)
                    .frame(height: 300)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .onChange(of: journalText) { _, newValue in
                        if !isGaslighted {
                            originalText = newValue
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
                        Text("🤖")
                            .font(.caption)
                        Slider(value: $realityLevel, in: 0...1, step: 0.1)
                        Text("✍️")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: gaslightEntry) {
                            Text("Edit for Me")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        Button(action: writeForMe) {
                            Text("Write for Me")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    if isGaslighted {
                        Button(action: revertToOriginal) {
                            Text("Revert to Original")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
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
            .navigationTitle("")
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
    }
    
    private func saveEntry() {
        guard !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let entryType: EntryType = isGaslighted ? .aiEnhanced : .userWritten
        let content = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
        let original = isGaslighted ? originalText.trimmingCharacters(in: .whitespacesAndNewlines) : nil
        
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
            realityLevel = 1.0
            isGaslighted = false
            selectedDate = Date() // Reset to current date/time
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSavedMessage = false
            }
        } catch {
            print("Failed to save entry: \(error)")
        }
    }
    
    private func gaslightEntry() {
        guard !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let generator = AIEntryGenerator.shared
        let gaslightedContent = generator.enhanceUserEntry(originalText, realityLevel: realityLevel)
        
        journalText = gaslightedContent
        isGaslighted = true
    }
    
    private func revertToOriginal() {
        journalText = originalText
        isGaslighted = false
    }
    
    private func writeForMe() {
        let generator = AIEntryGenerator.shared
        let additionalText = generator.generateContinuation(for: originalText, realityLevel: realityLevel)
        
        // Append the generated text to existing content
        if !journalText.isEmpty {
            journalText += "\n\n" + additionalText
        } else {
            journalText = additionalText
        }
        
        // Update original text to include the new content
        originalText = journalText
    }
}
