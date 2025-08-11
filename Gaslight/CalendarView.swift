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
    case day = "Day"
    case month = "Month" 
    case week = "Week"
    case year = "Year"
    
    var systemImage: String {
        switch self {
        case .day:
            return "calendar.circle"
        case .month:
            return "calendar"
        case .week:
            return "calendar.badge.exclamationmark"
        case .year:
            return "calendar.badge.clock"
        }
    }
    
    var shortName: String {
        switch self {
        case .day:
            return "D"
        case .month:
            return "M"
        case .week:
            return "W"
        case .year:
            return "Y"
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
                
                // Calendar Display
                Group {
                    switch displayMode {
                    case .day:
                        DayCalendarView(
                            selectedDate: $selectedDate,
                            entriesPerDate: entriesPerDate
                        )
                    case .month:
                        CustomCalendarView(
                            selectedDate: $selectedDate,
                            datesWithEntries: datesWithEntries,
                            entriesPerDate: entriesPerDate
                        )
                    case .week:
                        WeekCalendarView(
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
                
                // Legend
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.blue.opacity(0.3))
                            .frame(width: 12, height: 12)
                        Text("Real Entries")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.orange.opacity(0.3))
                            .frame(width: 12, height: 12)
                        Text("AI Entries")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    HStack(spacing: 6) {
                        ZStack {
                            Rectangle()
                                .fill(.orange.opacity(0.3))
                                .frame(width: 12, height: 12)
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: 12, y: 0))
                                path.addLine(to: CGPoint(x: 0, y: 12))
                                path.closeSubpath()
                            }
                            .fill(.blue.opacity(0.3))
                            .frame(width: 12, height: 12)
                        }
                        Text("Mixed")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
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

struct DayCalendarView: View {
    @Binding var selectedDate: Date
    let entriesPerDate: [String: [JournalEntry]]
    
    private let calendar = Calendar.current
    private let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()
    
    private var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }
    
    private var entriesForDay: [JournalEntry] {
        return entriesPerDate[dateKey] ?? []
    }
    
    private var hourlyEntries: [(hour: Int, entries: [JournalEntry])] {
        let grouped = Dictionary(grouping: entriesForDay) { entry in
            calendar.component(.hour, from: entry.createdDate)
        }
        
        return (0...23).map { hour in
            (hour: hour, entries: grouped[hour] ?? [])
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Day header with navigation
            HStack {
                Button(action: previousDay) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack {
                    Text(dayFormatter.string(from: selectedDate))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if entriesForDay.isEmpty {
                        Text("No entries")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(entriesForDay.count) entries")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Button(action: nextDay) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Hourly timeline
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(hourlyEntries, id: \.hour) { hourData in
                        HourRowView(
                            hour: hourData.hour,
                            entries: hourData.entries,
                            selectedDate: selectedDate
                        )
                    }
                }
            }
        }
        .padding(.vertical)
    }
    
    private func previousDay() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func nextDay() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        }
    }
}

struct HourRowView: View {
    let hour: Int
    let entries: [JournalEntry]
    let selectedDate: Date
    
    private var hourString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let hourDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate) ?? selectedDate
        return formatter.string(from: hourDate)
    }
    
    private var isCurrentHour: Bool {
        let now = Date()
        return Calendar.current.isDate(selectedDate, inSameDayAs: now) && 
               Calendar.current.component(.hour, from: now) == hour
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Hour label
            VStack {
                Text(hourString)
                    .font(.caption)
                    .fontWeight(isCurrentHour ? .bold : .medium)
                    .foregroundColor(isCurrentHour ? .blue : .secondary)
                    .frame(width: 50, alignment: .trailing)
                
                if isCurrentHour {
                    Circle()
                        .fill(.blue)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: entries.isEmpty ? 30 : nil)
            
            // Timeline line
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1)
                .frame(height: entries.isEmpty ? 30 : nil)
            
            // Entries for this hour
            VStack(alignment: .leading, spacing: 8) {
                if entries.isEmpty {
                    Spacer()
                        .frame(height: 30)
                } else {
                    ForEach(entries.sorted(by: { $0.createdDate < $1.createdDate })) { entry in
                        HourEntryView(entry: entry)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
}

struct HourEntryView: View {
    let entry: JournalEntry
    
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
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: entry.createdDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Circle()
                    .fill(entryTypeColor)
                    .frame(width: 6, height: 6)
            }
            
            Text(entry.content)
                .font(.caption)
                .lineLimit(3)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(entryTypeColor.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(entryTypeColor.opacity(0.3), lineWidth: 1)
        )
    }
}

struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    let datesWithEntries: Set<String>
    let entriesPerDate: [String: [JournalEntry]]
    
    private let calendar = Calendar.current
    
    private var weekDays: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = weekInterval.start
        
        while currentDate < weekInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private var weekRangeText: String {
        guard let first = weekDays.first, let last = weekDays.last else {
            return ""
        }
        
        let firstFormatter = DateFormatter()
        firstFormatter.dateFormat = "MMMM d"
        
        let lastFormatter = DateFormatter()
        if calendar.isDate(first, equalTo: last, toGranularity: .month) {
            lastFormatter.dateFormat = "d, yyyy"
        } else {
            lastFormatter.dateFormat = "MMMM d, yyyy"
        }
        
        return "\(firstFormatter.string(from: first)) - \(lastFormatter.string(from: last))"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Week header with navigation
            HStack {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(weekRangeText)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Week days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(weekDays, id: \.self) { date in
                    WeekDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        entries: getEntriesForDate(date)
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical)
    }
    
    private func previousWeek() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func nextWeek() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func getEntriesForDate(_ date: Date) -> [JournalEntry] {
        let dateKey = dateString(from: date)
        return entriesPerDate[dateKey] ?? []
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct WeekDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let entries: [JournalEntry]
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var realCount: Int {
        entries.filter { $0.entryType == .userWritten }.count
    }
    
    private var aiCount: Int {
        entries.filter { $0.entryType == .aiGenerated || $0.entryType == .aiEnhanced }.count
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if !entries.isEmpty {
            if realCount > 0 && aiCount > 0 {
                return .clear // Will use split background
            } else if realCount > 0 {
                return .blue.opacity(0.3)
            } else {
                return .orange.opacity(0.3)
            }
        } else {
            return .clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else {
            return .primary
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(weekdayName)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .frame(height: 80)
                
                // Split background for mixed entries
                if realCount > 0 && aiCount > 0 && !isSelected {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.orange.opacity(0.3))
                        
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: 80, y: 0))
                            path.addLine(to: CGPoint(x: 0, y: 80))
                            path.closeSubpath()
                        }
                        .fill(.blue.opacity(0.3))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(height: 80)
                }
                
                // Today indicator
                if isToday && !isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.blue, lineWidth: 2)
                        .frame(height: 80)
                }
                
                // Content
                VStack(spacing: 4) {
                    Text(dayNumber)
                        .font(.title3)
                        .fontWeight(isToday ? .bold : .medium)
                        .foregroundColor(textColor)
                    
                    if !entries.isEmpty {
                        VStack(spacing: 2) {
                            Text("\(entries.count)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(textColor.opacity(0.8))
                            
                            if realCount > 0 && aiCount > 0 {
                                HStack(spacing: 4) {
                                    Text("\(realCount)")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                    Text("/")
                                        .font(.caption2)
                                        .foregroundColor(textColor.opacity(0.5))
                                    Text("\(aiCount)")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }
            }
        }
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
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
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
        VStack(spacing: 16) {
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
            
            // Month grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 16) {
                ForEach(monthsInYear, id: \.self) { month in
                    MonthSummaryView(
                        month: month,
                        selectedDate: $selectedDate,
                        entriesPerDate: entriesPerDate
                    )
                    .onTapGesture {
                        selectedDate = month
                    }
                }
            }
            .padding(.horizontal)
            
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

struct MonthSummaryView: View {
    let month: Date
    @Binding var selectedDate: Date
    let entriesPerDate: [String: [JournalEntry]]
    
    private let calendar = Calendar.current
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    private var isCurrentMonth: Bool {
        calendar.isDate(month, equalTo: Date(), toGranularity: .month)
    }
    
    private var isSelectedMonth: Bool {
        calendar.isDate(month, equalTo: selectedDate, toGranularity: .month)
    }
    
    private var entriesInMonth: [JournalEntry] {
        let monthStart = calendar.dateInterval(of: .month, for: month)?.start ?? month
        let monthEnd = calendar.dateInterval(of: .month, for: month)?.end ?? month
        
        return entriesPerDate.values.flatMap { $0 }.filter { entry in
            entry.createdDate >= monthStart && entry.createdDate < monthEnd
        }
    }
    
    private var filteredEntriesInMonth: [JournalEntry] {
        return entriesInMonth // Show all entries without filtering
    }
    
    private var realCount: Int {
        entriesInMonth.filter { $0.entryType == .userWritten }.count
    }
    
    private var aiCount: Int {
        entriesInMonth.filter { $0.entryType == .aiGenerated || $0.entryType == .aiEnhanced }.count
    }
    
    private var backgroundColor: Color {
        if isSelectedMonth {
            return .blue.opacity(0.2)
        } else if isCurrentMonth {
            return .blue.opacity(0.1)
        } else {
            return Color(.systemBackground)
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(monthFormatter.string(from: month))
                .font(.headline)
                .fontWeight(isCurrentMonth ? .bold : .medium)
                .foregroundColor(isSelectedMonth ? .blue : .primary)
            
            VStack(spacing: 4) {
                if filteredEntriesInMonth.isEmpty {
                    Text("No entries")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    Text("\(filteredEntriesInMonth.count) entries")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if realCount > 0 && aiCount > 0 {
                        HStack(spacing: 8) {
                            HStack(spacing: 2) {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 4, height: 4)
                                Text("\(realCount)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            HStack(spacing: 2) {
                                Circle()
                                    .fill(.orange)
                                    .frame(width: 4, height: 4)
                                Text("\(aiCount)")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelectedMonth ? .blue : Color.gray.opacity(0.2), lineWidth: isSelectedMonth ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
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

