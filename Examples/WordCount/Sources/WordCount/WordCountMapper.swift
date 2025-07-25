//
//  WordCountMapper.swift
//  WordCount
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation
import SwiftStream

public struct WordCountMapper: Mapper {
    public typealias KOut = String
    public typealias VOut = Int
    
    public init() {}
    
    public func map(key: String, value: String, ctx: Context<String, Int>) {
        let line = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !line.isEmpty else {
            return
        }
        
        // Split line into words, removing punctuation and converting to lowercase
        let words = line.lowercased()
            .components(separatedBy: .punctuationCharacters.union(.whitespacesAndNewlines))
            .filter { !$0.isEmpty }
        
        // Emit each word with count of 1
        for word in words {
            ctx.emit(word, 1)
            ctx.incrementCounter(group: "WordCount", name: "words_processed", by: 1)
        }
        
        ctx.incrementCounter(group: "WordCount", name: "lines_processed", by: 1)
    }
}