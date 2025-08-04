//
//  EditEntryView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI
import SwiftData

struct EditEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedContent: String
    @State private var showSavedMessage: Bool = false
    
    let entry: JournalEntry
    
    init(entry: JournalEntry) {
        self.entry = entry
        self._editedContent = State(initialValue: entry.content)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Entry context info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Editing entry from:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(entry.formattedDate)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if entry.isAIGenerated {
                        HStack {
                            Text(entry.entryType.emoji)
                                .font(.caption)
                            Text("\(entry.entryType.displayName) • \(entry.realityPercentage) Real")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                TextEditor(text: $editedContent)
                    .frame(height: 300)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                if showSavedMessage {
                    Text("✅ Changes saved!")
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        guard !editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        entry.updateContent(editedContent.trimmingCharacters(in: .whitespacesAndNewlines))
        
        do {
            try modelContext.save()
            showSavedMessage = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSavedMessage = false
                dismiss()
            }
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}