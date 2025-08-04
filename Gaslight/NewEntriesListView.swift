//
//  NewEntriesListView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI
import SwiftData

struct NewEntriesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdDate, order: .reverse) private var entries: [JournalEntry]
    @State private var selectedEntry: JournalEntry?
    @State private var showingEditSheet = false
    @State private var showingWriteForMeSheet = false
    
    
    private var groupedEntries: [(String, [JournalEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: entry.createdDate)
            let date = calendar.date(from: dateComponents) ?? entry.createdDate
            return date
        }
        
        return grouped
            .sorted { $0.key < $1.key }
            .map { (dateString(from: $0.key), $0.value.sorted { $0.createdDate > $1.createdDate }) }
    }
    
    private var todaySection: String {
        let today = Calendar.current.startOfDay(for: Date())
        return dateString(from: today)
    }
    
    private var mostRecentEntry: JournalEntry? {
        return entries.sorted { $0.createdDate > $1.createdDate }.first
    }
    
    private var topSpacerView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "hourglass")
                    .font(.title2)
                    .foregroundColor(.gray.opacity(0.6))
                
                Text("The beginning of your story...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
                    .multilineTextAlignment(.center)
                
                Text("Or is it?")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
                    .italic()
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
            
            Spacer()
                .frame(height: 60)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .id("top_spacer")
    }
    
    private var bottomSpacerView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)
            
            VStack(spacing: 12) {
                Text("You've reached the end of your journal entries...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
                    .multilineTextAlignment(.center)
                
                Text("unless you know what happens in the future?")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
                    .italic()
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .id("bottom_spacer")
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("No entries yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Start writing to see your entries here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                List {
                    topSpacerView
                    
                    ForEach(groupedEntries, id: \.0) { dateString, dayEntries in
                        Section {
                            ForEach(dayEntries) { entry in
                                EntryCardView(
                                    entry: entry, 
                                    isLatest: entry.id == mostRecentEntry?.id,
                                    onEditEntry: {
                                        selectedEntry = entry
                                        showingEditSheet = true
                                    },
                                    onWriteForMe: {
                                        selectedEntry = entry
                                        showingWriteForMeSheet = true
                                    }
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .id("entry_\(entry.createdDate.timeIntervalSince1970)")
                            }
                        } header: {
                            HStack {
                                Text(formatSectionDate(dateString))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(dayEntries.count) entries")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .id(dateString)
                    }
                    
                    if entries.isEmpty {
                        emptyStateView
                    }
                    
                    bottomSpacerView
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    // Always scroll to most recent entry and center it
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let mostRecentEntry = mostRecentEntry {
                            let entryID = "entry_\(mostRecentEntry.createdDate.timeIntervalSince1970)"
                            print("Scrolling to latest entry: \(entryID)")
                            withAnimation(.easeInOut(duration: 0.15)) {
                                proxy.scrollTo(entryID, anchor: .center)
                            }
                        } else {
                            print("No recent entry found, scrolling to today section")
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo(todaySection, anchor: .top)
                            }
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditSheet) {
                if let entry = selectedEntry {
                    EditEntryView(entry: entry)
                }
            }
            .sheet(isPresented: $showingWriteForMeSheet) {
                if let entry = selectedEntry {
                    WriteForMeView(entry: entry)
                }
            }
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatSectionDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let entryDate = calendar.startOfDay(for: date)
        
        if entryDate == today {
            return "Today"
        } else if entryDate == yesterday {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            // Same year, show month and day
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMMM d"
            return displayFormatter.string(from: date)
        } else {
            // Different year, show full date
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMMM d, yyyy"
            return displayFormatter.string(from: date)
        }
    }
}

struct EntryCardView: View {
    let entry: JournalEntry
    let isLatest: Bool
    let onEditEntry: () -> Void
    let onWriteForMe: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Green line for latest entry
            if isLatest {
                Rectangle()
                    .fill(Color.green)
                    .frame(height: 3)
            }
            
            VStack(alignment: .leading, spacing: 12) {
            // Header with time and type
            HStack {
                Text(timeString(from: entry.createdDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(entry.entryType.emoji)
                        .font(.caption)
                    Text(entry.entryType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if entry.isAIGenerated {
                        Text("(\(entry.realityPercentage))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Entry content
            Text(entry.content)
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            // Footer with edit indicator and action buttons
            VStack(alignment: .leading, spacing: 8) {
                if entry.entryType == .aiEnhanced && entry.originalContent != nil {
                    HStack {
                        Image(systemName: "pencil.and.outline")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("Modified from original")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: onEditEntry) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.caption)
                            Text("Edit My Entry")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                    
                    Button(action: onWriteForMe) {
                        HStack(spacing: 4) {
                            Image(systemName: "text.badge.plus")
                                .font(.caption)
                            Text("Write for Me")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
            }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.7), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}