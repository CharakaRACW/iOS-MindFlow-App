//
//  SentimentAnalyzer.swift
//  MindFlow
//
//  Created by Charaka Ilangarathne on 2025-11-25.
//
//  Uses Apple's NLTagger with CoreML-based sentiment analysis
//  This fulfills the "emerging technology" requirement
//

import Foundation
import NaturalLanguage
import SwiftUI

struct SentimentAnalyzer {
    
    // MARK: - Analyze Text
    /// Analyzes the sentiment of a given text using Apple's NLTagger
    /// - Parameter text: The text to analyze
    /// - Returns: A sentiment score between -1.0 (very negative) and 1.0 (very positive)
    ///   - -1.0 to -0.3: Negative sentiment
    ///   - -0.3 to 0.3: Neutral sentiment
    ///   - 0.3 to 1.0: Positive sentiment
    static func analyze(text: String) -> Double {
        // Handle empty text
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return 0.0
        }
        
        // Create NLTagger with sentiment score scheme
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        // Get sentiment score for the entire text
        let (sentiment, _) = tagger.tag(
            at: text.startIndex,
            unit: .paragraph,
            scheme: .sentimentScore
        )
        
        // Parse the sentiment score
        if let sentimentValue = sentiment?.rawValue,
           let score = Double(sentimentValue) {
            // Clamp to range -1.0 to 1.0
            return max(-1.0, min(1.0, score))
        }
        
        // Return neutral if analysis fails
        return 0.0
    }
    
    // MARK: - Get Sentiment Color
    /// Returns a color based on the sentiment score
    /// - Parameter score: The sentiment score (-1.0 to 1.0)
    /// - Returns: Color representing the sentiment
    ///   - Orange (primaryOrange): Positive sentiment (> 0.3)
    ///   - Red: Negative sentiment (< -0.3)
    ///   - Gray: Neutral sentiment
    static func getSentimentColor(_ score: Double) -> Color {
        if score > 0.3 {
            return Color.primaryOrange
        } else if score < -0.3 {
            return Color.red
        } else {
            return Color.gray
        }
    }
    
    // MARK: - Get Sentiment Label
    /// Returns a human-readable label for the sentiment score
    /// - Parameter score: The sentiment score (-1.0 to 1.0)
    /// - Returns: A string label describing the sentiment
    static func getSentimentLabel(_ score: Double) -> String {
        switch score {
        case 0.6...1.0:
            return "Very Positive"
        case 0.3..<0.6:
            return "Positive"
        case -0.3..<0.3:
            return "Neutral"
        case -0.6..<(-0.3):
            return "Negative"
        default:
            return "Very Negative"
        }
    }
    
    // MARK: - Get Sentiment Emoji
    /// Returns an emoji representing the sentiment
    /// - Parameter score: The sentiment score (-1.0 to 1.0)
    /// - Returns: An emoji string
    static func getSentimentEmoji(_ score: Double) -> String {
        switch score {
        case 0.6...1.0:
            return "😄"
        case 0.3..<0.6:
            return "🙂"
        case -0.3..<0.3:
            return "😐"
        case -0.6..<(-0.3):
            return "😟"
        default:
            return "😢"
        }
    }
}
