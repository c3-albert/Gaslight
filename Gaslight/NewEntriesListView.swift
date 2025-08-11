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
    @State private var showingWriteForMeSheet = false
    @State private var searchText = ""
    
    private var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { entry in
                entry.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var groupedEntries: [(String, [JournalEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEntries) { entry in
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
        return filteredEntries.sorted { $0.createdDate > $1.createdDate }.first
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
            Image(systemName: searchText.isEmpty ? "book.closed" : "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text(searchText.isEmpty ? "No entries yet" : "No results found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(searchText.isEmpty ? "Start writing to see your entries here" : "Try adjusting your search terms")
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
            VStack(spacing: 0) {
                // Search bar anchored at top
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search entries...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    if !searchText.isEmpty {
                        Button("Cancel") {
                            searchText = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .foregroundColor(.blue)
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color(.systemBackground))
                
                // Main content with scroll reader
                ScrollViewReader { proxy in
                    List {
                        if !searchText.isEmpty {
                            // Show search results without spacers
                            ForEach(groupedEntries, id: \.0) { dateString, dayEntries in
                                Section {
                                    ForEach(dayEntries) { entry in
                                        EntryCardView(
                                            entry: entry, 
                                            isLatest: entry.id == mostRecentEntry?.id,
                                            onWriteForMe: {
                                                selectedEntry = entry
                                                showingWriteForMeSheet = true
                                            },
                                            searchText: searchText
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
                        } else {
                            // Show normal view with spacers when not searching
                            topSpacerView
                            
                            ForEach(groupedEntries, id: \.0) { dateString, dayEntries in
                                Section {
                                    ForEach(dayEntries) { entry in
                                        EntryCardView(
                                            entry: entry, 
                                            isLatest: entry.id == mostRecentEntry?.id,
                                            onWriteForMe: {
                                                selectedEntry = entry
                                                showingWriteForMeSheet = true
                                            },
                                            searchText: ""
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
                    }
                    .listStyle(PlainListStyle())
                    .onAppear {
                        // Only scroll to recent entry when not searching
                        if searchText.isEmpty {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if let mostRecentEntry = mostRecentEntry {
                                    let entryID = "entry_\(mostRecentEntry.createdDate.timeIntervalSince1970)"
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        proxy.scrollTo(entryID, anchor: .center)
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo(todaySection, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Entry History")
            .navigationBarTitleDisplayMode(.large)
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
    let onWriteForMe: () -> Void
    let searchText: String
    
    private var entryTypeColor: Color {
        switch entry.entryType {
        case .userWritten:
            return .blue
        case .aiGenerated:
            return .orange
        case .aiEnhanced:
            return Color.orange.opacity(0.7)
        }
    }
    
    private var borderWidth: CGFloat {
        return isLatest ? 4 : 3
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Colored line for entry type
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: isLatest ? [entryTypeColor, entryTypeColor.opacity(0.6)] : [entryTypeColor]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: borderWidth)
            
            VStack(alignment: .leading, spacing: 12) {
            // Header with time and type
            HStack {
                Text(timeString(from: entry.createdDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 6) {
                    // Color-coded type indicator
                    Circle()
                        .fill(entryTypeColor)
                        .frame(width: 8, height: 8)
                    
                    Text(entry.entryType.displayName)
                        .font(.caption)
                        .foregroundColor(entryTypeColor)
                        .fontWeight(.medium)
                    
                    if entry.isAIGenerated {
                        Text("(\(entry.realityPercentage))")
                            .font(.caption)
                            .foregroundColor(entryTypeColor.opacity(0.8))
                    }
                }
            }
            
            // Entry content with search highlighting
            HighlightedText(
                text: entry.content,
                searchText: searchText,
                font: .body,
                baseColor: .primary
            )
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
                .stroke(entryTypeColor.opacity(0.3), lineWidth: isLatest ? 2 : 1)
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