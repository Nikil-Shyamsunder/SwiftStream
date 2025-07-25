//
//  WordCountReducer.swift
//  WordCount
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation
import SwiftStream

public struct WordCountReducer: Reducer {
    public typealias KIn = String
    public typealias VIn = Int
    public typealias KOut = String
    public typealias VOut = Int
    
    public init() {}
    
    public func reduce(key: String, values: AnyIterator<Int>, ctx: Context<String, Int>) {
        var totalCount = 0
        
        // Sum all the counts for this word
        for count in values {
            totalCount += count
        }
        
        // Emit the word and its total count
        ctx.emit(key, totalCount)
        ctx.incrementCounter(group: "WordCount", name: "words_reduced", by: 1)
    }
}