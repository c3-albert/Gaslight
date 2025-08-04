//
//  JournalEntry.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import Foundation
import SwiftData

@Model
final class JournalEntry {
    var content: String
    var createdDate: Date
    var modifiedDate: Date
    var title: String?
    var entryTypeRaw: String
    var realityLevel: Double
    var originalContent: String?
    
    var entryType: EntryType {
        get { EntryType(rawValue: entryTypeRaw) ?? .userWritten }
        set { entryTypeRaw = newValue.rawValue }
    }
    
    init(content: String, title: String? = nil, entryType: EntryType = .userWritten, realityLevel: Double = 1.0, originalContent: String? = nil, createdDate: Date = Date()) {
        self.content = content
        self.title = title
        self.entryTypeRaw = entryType.rawValue
        self.realityLevel = realityLevel
        self.originalContent = originalContent
        self.createdDate = createdDate
        self.modifiedDate = Date()
    }
    
    func updateContent(_ newContent: String, title: String? = nil) {
        self.content = newContent
        self.title = title
        self.modifiedDate = Date()
    }
    
    var displayTitle: String {
        if let title = title, !title.isEmpty {
            return title
        }
        
        let words = content.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        if words.isEmpty {
            return "Untitled Entry"
        }
        
        let firstFewWords = words.prefix(5).joined(separator: " ")
        return firstFewWords.count > 50 ? String(firstFewWords.prefix(50)) + "..." : firstFewWords
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdDate)
    }
    
    var realityPercentage: String {
        return "\(Int(realityLevel * 100))%"
    }
    
    var isAIGenerated: Bool {
        return entryType == .aiGenerated || entryType == .aiEnhanced
    }
    
    var displayTitleWithReality: String {
        let title = displayTitle
        if isAIGenerated {
            return "\(entryType.emoji) \(title)"
        }
        return title
    }
}