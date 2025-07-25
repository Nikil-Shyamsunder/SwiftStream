//
//  WordCountTests.swift
//  WordCountTests
//
//  Copyright Nikil Shyamsunder 2025
//

import XCTest
import SwiftStream
@testable import WordCount

final class WordCountTests: XCTestCase {
    func testWordCountMapper() throws {
        let input = [
            ("line1", "Hello world"),
            ("line2", "Hello Swift programming"),
            ("line3", "World of programming")
        ]
        
        let results = StreamTestHarness.runMapper(WordCountMapper.self, input: input)
        
        // Should have 7 total words
        XCTAssertEqual(results.count, 7)
        
        // Check specific words
        let wordCounts = Dictionary(grouping: results, by: { $0.key })
            .mapValues { $0.count }
        
        XCTAssertEqual(wordCounts["hello"], 2)
        XCTAssertEqual(wordCounts["world"], 2)
        XCTAssertEqual(wordCounts["programming"], 2)
        XCTAssertEqual(wordCounts["swift"], 1)
        XCTAssertEqual(wordCounts["of"], 1)
    }
    
    func testWordCountReducer() throws {
        let input = [
            ("hello", [1, 1]),
            ("world", [1, 1]),
            ("programming", [1, 1]),
            ("swift", [1])
        ]
        
        let results = StreamTestHarness.runReducer(WordCountReducer.self, input: input)
        
        let resultDict = Dictionary(uniqueKeysWithValues: results.map { ($0.key, $0.value) })
        
        XCTAssertEqual(resultDict["hello"], 2)
        XCTAssertEqual(resultDict["world"], 2)
        XCTAssertEqual(resultDict["programming"], 2)
        XCTAssertEqual(resultDict["swift"], 1)
    }
}