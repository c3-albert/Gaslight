//
//  HighlightedText.swift
//  Gaslight
//
//  Created by Albert Xu on 8/11/25.
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let searchText: String
    let font: Font
    let baseColor: Color
    let highlightColor: Color
    let highlightBackground: Color
    
    init(
        text: String,
        searchText: String,
        font: Font = .body,
        baseColor: Color = .primary,
        highlightColor: Color = .white,
        highlightBackground: Color = .orange
    ) {
        self.text = text
        self.searchText = searchText
        self.font = font
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.highlightBackground = highlightBackground
    }
    
    var body: some View {
        if searchText.isEmpty {
            Text(text)
                .font(font)
                .foregroundColor(baseColor)
        } else {
            Text(attributedText)
                .font(font)
        }
    }
    
    private var attributedText: AttributedString {
        guard !searchText.isEmpty else {
            var result = AttributedString(text)
            result.foregroundColor = baseColor
            return result
        }
        
        let lowercaseText = text.lowercased()
        let lowercaseSearch = searchText.lowercased()
        
        var attributedString = AttributedString()
        var currentIndex = text.startIndex
        
        while currentIndex < text.endIndex {
            if let foundRange = lowercaseText.range(of: lowercaseSearch, range: currentIndex..<text.endIndex) {
                // Add non-highlighted text before the match
                if currentIndex < foundRange.lowerBound {
                    let beforeText = String(text[currentIndex..<foundRange.lowerBound])
                    var beforeAttr = AttributedString(beforeText)
                    beforeAttr.foregroundColor = baseColor
                    attributedString.append(beforeAttr)
                }
                
                // Add highlighted match
                let matchText = String(text[foundRange.lowerBound..<foundRange.upperBound])
                var matchAttr = AttributedString(matchText)
                matchAttr.foregroundColor = highlightColor
                matchAttr.backgroundColor = highlightBackground
                attributedString.append(matchAttr)
                
                currentIndex = foundRange.upperBound
            } else {
                // Add remaining non-highlighted text
                if currentIndex < text.endIndex {
                    let remainingText = String(text[currentIndex..<text.endIndex])
                    var remainingAttr = AttributedString(remainingText)
                    remainingAttr.foregroundColor = baseColor
                    attributedString.append(remainingAttr)
                }
                break
            }
        }
        
        return attributedString
    }
}

#Preview {
    VStack(spacing: 20) {
        HighlightedText(
            text: "This is a sample text with some words to highlight",
            searchText: "sample"
        )
        
        HighlightedText(
            text: "Multiple matches: test and TEST and Test should all highlight",
            searchText: "test"
        )
        
        HighlightedText(
            text: "No matches here",
            searchText: "xyz"
        )
        
        HighlightedText(
            text: "Today I went to the store and bought some groceries. The weather was beautiful and I enjoyed the walk.",
            searchText: "the",
            font: .body
        )
    }
    .padding()
}