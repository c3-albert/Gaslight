//
//  CustomCalendarView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI
import Foundation

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    let datesWithEntries: Set<String>
    let entryFilter: EntryFilter
    let entriesPerDate: [String: [JournalEntry]]
    
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let daysToSubtract = firstWeekday - 1
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstOfMonth) else {
            return []
        }
        
        var days: [Date] = []
        for i in 0..<42 { // 6 weeks * 7 days
            if let day = calendar.date(byAdding: .day, value: i, to: startDate) {
                days.append(day)
            }
        }
        return days
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header with navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(monthFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(daysInMonth, id: \.self) { date in
                    DateCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        isToday: calendar.isDateInToday(date),
                        hasEntries: datesWithEntries.contains(dateString(from: date)),
                        entryInfo: getEntryInfo(for: date),
                        entryFilter: entryFilter
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func dateString(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    private func getEntryInfo(for date: Date) -> EntryInfo {
        let dateStr = dateString(from: date)
        let entries = entriesPerDate[dateStr] ?? []
        
        let realCount = entries.filter { $0.entryType == .userWritten }.count
        let aiCount = entries.filter { $0.entryType == .aiGenerated || $0.entryType == .aiEnhanced }.count
        
        return EntryInfo(realCount: realCount, aiCount: aiCount)
    }
}

struct EntryInfo {
    let realCount: Int
    let aiCount: Int
    
    var totalCount: Int { realCount + aiCount }
    var hasReal: Bool { realCount > 0 }
    var hasAI: Bool { aiCount > 0 }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let hasEntries: Bool
    let entryInfo: EntryInfo
    let entryFilter: EntryFilter
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var shouldShowSplitBackground: Bool {
        return entryFilter == .all && entryInfo.hasReal && entryInfo.hasAI
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if hasEntries && !shouldShowSplitBackground {
            switch entryFilter {
            case .all:
                if entryInfo.hasReal {
                    return .green.opacity(0.3)
                } else {
                    return .orange.opacity(0.3)
                }
            case .real:
                return entryInfo.hasReal ? .green.opacity(0.3) : .clear
            case .ai:
                return entryInfo.hasAI ? .orange.opacity(0.3) : .clear
            }
        } else {
            return .clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if !isCurrentMonth {
            return .secondary
        } else {
            return .primary
        }
    }
    
    var body: some View {
        ZStack {
            // Background square
            Rectangle()
                .fill(backgroundColor)
            
            // Split background for days with both real and AI entries
            if shouldShowSplitBackground {
                ZStack {
                    // AI triangle (bottom right)
                    TriangleShape(pointPosition: .bottomRight)
                        .fill(.orange.opacity(0.3))
                    
                    // Real triangle (top left)
                    TriangleShape(pointPosition: .topLeft)
                        .fill(.green.opacity(0.3))
                }
            }
            
            // Today indicator
            if isToday && !isSelected {
                Rectangle()
                    .stroke(Color.blue, lineWidth: 2)
            }
            
            // Selected indicator
            if isSelected {
                Rectangle()
                    .fill(.blue)
            }
            
            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
                
                if hasEntries && entryInfo.totalCount > 1 {
                    Circle()
                        .fill(textColor.opacity(0.6))
                        .frame(width: 4, height: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
}

// Custom triangle shape
struct TriangleShape: Shape {
    enum PointPosition {
        case topLeft
        case bottomRight
    }
    
    let pointPosition: PointPosition
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch pointPosition {
        case .topLeft:
            // Triangle with right angle at top-left
            path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // Top-left corner
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // Top-right corner
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // Bottom-left corner
            path.closeSubpath()
        case .bottomRight:
            // Triangle with right angle at bottom-right
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Bottom-right corner
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // Bottom-left corner
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // Top-right corner
            path.closeSubpath()
        }
        
        return path
    }
}