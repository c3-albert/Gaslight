//
//  CalendarView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI
import SwiftData

enum EntryFilter: String, CaseIterable {
    case all = "All"
    case real = "Real Only"
    case ai = "AI Only"
    
    var themeColor: Color {
        switch self {
        case .all:
            return .primary
        case .real:
            return .blue
        case .ai:
            return .orange
        }
    }
}

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [JournalEntry]
    
    @State private var selectedDate = Date()
    @State private var entryFilter: EntryFilter = .all
    @State private var selectedEntry: JournalEntry?
    
    private var filteredEntries: [JournalEntry] {
        switch entryFilter {
        case .all:
            return allEntries
        case .real:
            return allEntries.filter { $0.entryType == .userWritten }
        case .ai:
            return allEntries.filter { $0.entryType == .aiGenerated || $0.entryType == .aiEnhanced }
        }
    }
    
    private var entriesForSelectedDate: [JournalEntry] {
        filteredEntries.filter { Calendar.current.isDate($0.createdDate, inSameDayAs: selectedDate) }
    }
    
    private var datesWithEntries: Set<String> {
        Set(filteredEntries.map { dateString(from: $0.createdDate) })
    }
    
    private var entriesPerDate: [String: [JournalEntry]] {
        Dictionary(grouping: filteredEntries) { entry in
            dateString(from: entry.createdDate)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Toggle
                Picker("Entry Type", selection: $entryFilter) {
                    ForEach(EntryFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Custom Calendar
                CustomCalendarView(
                    selectedDate: $selectedDate,
                    datesWithEntries: datesWithEntries,
                    entryFilter: entryFilter,
                    entriesPerDate: entriesPerDate
                )
                
                Divider()
                
                // Entries for selected date
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Entries for \(selectedDate, style: .date)")
                            .font(.headline)
                        Spacer()
                        if !entriesForSelectedDate.isEmpty {
                            Text("\(entriesForSelectedDate.count) entries")
                                .font(.caption)
                                .foregroundColor(entryFilter.themeColor.opacity(0.8))
                        }
                    }
                    .padding(.horizontal)
                    
                    if entriesForSelectedDate.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No entries for this date")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(entriesForSelectedDate.sorted(by: { $0.createdDate > $1.createdDate })) { entry in
                                EntryRowView(entry: entry)
                                    .onTapGesture {
                                        selectedEntry = entry
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(item: $selectedEntry) { entry in
                EditEntryView(entry: entry)
            }
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct EntryRowView: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.displayTitleWithReality)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(entry.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(entry.entryType == .userWritten ? Color.blue : Color.orange)
                        .frame(width: 6, height: 6)
                    Text(entry.entryType.displayName)
                        .font(.caption)
                        .foregroundColor(entry.entryType == .userWritten ? .blue : .orange)
                }
                
                if entry.isAIGenerated {
                    Spacer()
                    Text("Reality: \(entry.realityPercentage)")
                        .font(.caption)
                        .foregroundColor(.orange.opacity(0.8))
                }
            }
        }
        .padding(.vertical, 4)
    }
}

