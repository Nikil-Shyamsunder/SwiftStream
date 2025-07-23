//
//  SwiftStreamTests.swift
//  SwiftStreamTests
//
//  Copyright Nikil Shyamsunder 2025
//

import Testing
import XCTest
@testable import SwiftStream


final class WordCountTest: XCTestCase {
    // perform the clasic word count example!
    struct WordCountMapper: Mapper {
        typealias KOut = String
        typealias VOut = Int
        
        init() {}
        
        func map(key: String, value: String, ctx: Context<String, Int>) {
            let words = value.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
            
            for word in words {
                ctx.emit(word, 1)
            }
        }
    }

    struct WordCountReducer: Reducer {
        typealias KIn = String
        typealias VIn = Int
        typealias KOut = String
        typealias VOut = Int
        
        init() {}
        
        func reduce(key: String, values: AnyIterator<Int>, ctx: Context<String, Int>) {
            let total = values.reduce(0, +)
            ctx.emit(key, total)
        }
    }
    
    // test the mapper individually
    func testWordCountMapper() {
        let input = [
            ("line1", "hello world"),
            ("line2", "hello swift world"),
            ("line3", "")
        ]
        
        let results = StreamTestHarness.runMapper(WordCountMapper.self, input: input)
        
        let expectedWords = ["hello", "world", "hello", "swift", "world"]
        XCTAssertEqual(results.count, expectedWords.count)
        
        for (result, expected) in zip(results, expectedWords) {
            XCTAssertEqual(result.key, expected)
            XCTAssertEqual(result.value, 1)
        }
    }
    
    // test the reducer individually
    func testWordCountReducer() {
        let input = [
            ("hello", [1, 1]),
            ("world", [1, 1]),
            ("swift", [1])
        ]
        
        let results = StreamTestHarness.runReducer(WordCountReducer.self, input: input)
        
        XCTAssertEqual(results.count, 3)
        
        let resultDict = Dictionary(results.map { ($0.key, $0.value) }, uniquingKeysWith: { $1 })
        XCTAssertEqual(resultDict["hello"], 2)
        XCTAssertEqual(resultDict["world"], 2)
        XCTAssertEqual(resultDict["swift"], 1)
    }
    
    // check that logging is performed as expected for mapper and reducer
    func testMapperContext() {
        let pipe = Pipe()
        let context = Context<String, Int>(outputHandle: pipe.fileHandleForWriting)
        
        context.emit("test", 42)
        context.incrementCounter(group: "TestGroup", name: "TestCounter", by: 5)
        context.setStatus("Processing...")
        
        pipe.fileHandleForWriting.closeFile()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        XCTAssertEqual(output, "test\t42\n")
        
        let counters = context.getCounters()
        XCTAssertEqual(counters["TestGroup"]?["TestCounter"], 5)
    }
    
    func testReducerContext() {
        let pipe = Pipe()
        let context = Context<String, Int>(outputHandle: pipe.fileHandleForWriting)
        
        context.emit("result", 100)
        context.incrementCounter(group: "ReduceGroup", name: "ReduceCounter", by: 3)
        
        pipe.fileHandleForWriting.closeFile()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        XCTAssertEqual(output, "result\t100\n")
        
        let counters = context.getCounters()
        XCTAssertEqual(counters["ReduceGroup"]?["ReduceCounter"], 3)
    }
}
