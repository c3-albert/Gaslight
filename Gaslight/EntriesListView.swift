//
//  EntriesListView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI
import SwiftData

struct EntriesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdDate, order: .reverse) private var entries: [JournalEntry]
    @State private var selectedEntry: JournalEntry?
    
    var body: some View {
        NavigationView {
            List {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Entries Yet",
                        systemImage: "book.closed",
                        description: Text("Start writing your first journal entry!")
                    )
                } else {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.displayTitle)
                                .font(.headline)
                                .lineLimit(2)
                            
                            Text(entry.content)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                            
                            Text(entry.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedEntry = entry
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            }
            .navigationTitle("Journal Entries")
            .sheet(item: $selectedEntry) { entry in
                EditEntryView(entry: entry)
            }
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(entries[index])
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Failed to delete entries: \(error)")
            }
        }
    }
}