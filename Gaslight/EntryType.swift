//
//  EntryType.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import Foundation

enum EntryType: String, CaseIterable, Codable {
    case userWritten = "user_written"
    case aiGenerated = "ai_generated"
    case aiEnhanced = "ai_enhanced"
    
    var displayName: String {
        switch self {
        case .userWritten:
            return "Real"
        case .aiGenerated:
            return "AI Generated"
        case .aiEnhanced:
            return "AI Enhanced"
        }
    }
    
    var emoji: String {
        switch self {
        case .userWritten:
            return "✍️"
        case .aiGenerated:
            return "🤖"
        case .aiEnhanced:
            return "✨"
        }
    }
    
    var themeColor: String {
        switch self {
        case .userWritten:
            return "blue"
        case .aiGenerated:
            return "orange"
        case .aiEnhanced:
            return "orange"
        }
    }
}