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

enum CalendarDisplayMode: String, CaseIterable {
    case month = "Month" 
    case year = "Year"
    
    var systemImage: String {
        switch self {
        case .month:
            return "calendar"
        case .year:
            return "calendar.badge.clock"
        }
    }
    
    var shortName: String {
        switch self {
        case .month:
            return "Month"
        case .year:
            return "Year"
        }
    }
}

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [JournalEntry]
    
    @State private var selectedDate = Date()
    @State private var selectedEntry: JournalEntry?
    @State private var displayMode: CalendarDisplayMode = .month
    
    private var entriesForSelectedDate: [JournalEntry] {
        allEntries.filter { Calendar.current.isDate($0.createdDate, inSameDayAs: selectedDate) }
    }
    
    private var datesWithEntries: Set<String> {
        Set(allEntries.map { dateString(from: $0.createdDate) })
    }
    
    private var entriesPerDate: [String: [JournalEntry]] {
        Dictionary(grouping: allEntries) { entry in
            dateString(from: entry.createdDate)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // DMWY Display Mode Toggle
                VStack(spacing: 12) {
                    HStack {
                        Text("Calendar View")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    Picker("Display Mode", selection: $displayMode) {
                        ForEach(CalendarDisplayMode.allCases, id: \.self) { mode in
                            Text(mode.shortName)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                
                // Calendar Display with wider margins
                Group {
                    switch displayMode {
                    case .month:
                        CustomCalendarView(
                            selectedDate: $selectedDate,
                            datesWithEntries: datesWithEntries,
                            entriesPerDate: entriesPerDate
                        )
                    case .year:
                        YearCalendarView(
                            selectedDate: $selectedDate,
                            datesWithEntries: datesWithEntries,
                            entriesPerDate: entriesPerDate
                        )
                    }
                }
                .padding(.horizontal, 32) // Even wider side margins
                
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
                                .foregroundColor(.secondary)
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



struct YearCalendarView: View {
    @Binding var selectedDate: Date
    let datesWithEntries: Set<String>
    let entriesPerDate: [String: [JournalEntry]]
    
    @State private var currentYear = Date()
    
    private let calendar = Calendar.current
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    private var monthsInYear: [Date] {
        var months: [Date] = []
        let year = calendar.component(.year, from: currentYear)
        
        for month in 1...12 {
            if let monthDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)) {
                months.append(monthDate)
            }
        }
        return months
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Year header with navigation
            HStack {
                Button(action: previousYear) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(yearFormatter.string(from: currentYear))
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: nextYear) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Legend moved to top after year header
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(.blue.opacity(0.3))
                        .frame(width: 12, height: 12)
                    Text("Real Entries")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(.orange.opacity(0.3))
                        .frame(width: 12, height: 12)
                    Text("AI Entries")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(.orange.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: 12, y: 0))
                                path.addLine(to: CGPoint(x: 0, y: 12))
                                path.closeSubpath()
                            }
                            .fill(.blue.opacity(0.3))
                        )
                    Text("Mixed")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Mini month calendars in 4x3 grid (smaller with wider margins)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 12) {
                ForEach(monthsInYear, id: \.self) { month in
                    MiniMonthView(
                        month: month,
                        selectedDate: $selectedDate,
                        entriesPerDate: entriesPerDate
                    )
                }
            }
            
            Spacer()
        }
        .padding(.vertical)
    }
    
    private func previousYear() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentYear = calendar.date(byAdding: .year, value: -1, to: currentYear) ?? currentYear
        }
    }
    
    private func nextYear() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentYear = calendar.date(byAdding: .year, value: 1, to: currentYear) ?? currentYear
        }
    }
}

struct MiniMonthView: View {
    let month: Date
    @Binding var selectedDate: Date
    let entriesPerDate: [String: [JournalEntry]]
    
    private let calendar = Calendar.current
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let daysToSubtract = firstWeekday - 1
        
        var days: [Date?] = []
        
        // Add empty days for the beginning of the month
        for _ in 0..<daysToSubtract {
            days.append(nil)
        }
        
        // Add actual days of the month
        var currentDate = firstOfMonth
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Fill remaining slots to complete the grid (6 rows x 7 days = 42 total)
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 3) {
            // Month name
            Text(monthFormatter.string(from: month))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Compact grid showing only actual month days
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(10), spacing: 1), count: 7), spacing: 1) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, day in
                    if let day = day {
                        MiniDayView(
                            date: day,
                            isSelected: calendar.isDate(day, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(day),
                            entries: getEntriesForDate(day)
                        )
                        .onTapGesture {
                            selectedDate = day
                        }
                    } else {
                        // Empty spacer for proper weekday alignment (transparent)
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 10, height: 10)
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6).opacity(0.2))
        )
    }
    
    private func getEntriesForDate(_ date: Date) -> [JournalEntry] {
        let dateKey = dateFormatter.string(from: date)
        return entriesPerDate[dateKey] ?? []
    }
}

struct MiniDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let entries: [JournalEntry]
    
    private let calendar = Calendar.current
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var realCount: Int {
        entries.filter { $0.entryType == .userWritten }.count
    }
    
    private var aiCount: Int {
        entries.filter { $0.entryType == .aiGenerated || $0.entryType == .aiEnhanced }.count
    }
    
    
    var body: some View {
        ZStack {
            // Cell background with entry type colors (like month view)
            if !entries.isEmpty {
                if realCount > 0 && aiCount > 0 {
                    // Mixed entries - split triangle fill (same opacity as pure real entries)
                    Rectangle()
                        .fill(.orange.opacity(0.3))
                        .overlay(
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: 10, y: 0))
                                path.addLine(to: CGPoint(x: 0, y: 10))
                                path.closeSubpath()
                            }
                            .fill(.blue.opacity(0.3))
                        )
                } else if realCount > 0 {
                    // Real entries only
                    Rectangle()
                        .fill(.blue.opacity(0.3))
                } else {
                    // AI entries only
                    Rectangle()
                        .fill(.orange.opacity(0.3))
                }
            } else {
                // Empty day - light background
                Rectangle()
                    .fill(Color(.systemGray6).opacity(0.3))
            }
            
            // Light grey borders
            Rectangle()
                .stroke(Color(.systemGray4), lineWidth: 0.5)
            
            // Selection indicator
            if isSelected {
                Rectangle()
                    .stroke(.blue, lineWidth: 2)
            } else if isToday {
                Rectangle()
                    .stroke(.blue.opacity(0.7), lineWidth: 1.5)
            }
        }
        .frame(width: 10, height: 10)
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

