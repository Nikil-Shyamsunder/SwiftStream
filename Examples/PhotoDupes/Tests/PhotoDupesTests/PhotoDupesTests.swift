//
//  main.swift
//  PhotoDupesCLI
//
//  Copyright Nikil Shyamsunder 2025
//

import XCTest
@testable import PhotoDupes
import SwiftStream

final class PhotoDupesTests: XCTestCase {
    
    // test that hamming distance works correctly
    func testImageHashing() {
        let hash1: UInt64 = 0b1010101010101010101010101010101010101010101010101010101010101010
        let hash2: UInt64 = 0b1010101010101010101010101010101010101010101010101010101010101011
        let hash3: UInt64 = 0b0101010101010101010101010101010101010101010101010101010101010101
        
        let hamming12 = ImageHashing.hamming(hash1, hash2)
        let hamming13 = ImageHashing.hamming(hash1, hash3)
        
        XCTAssertEqual(hamming12, 1)
        XCTAssertEqual(hamming13, 64)
    }
    
    // test mapper 
    func testPhotoMapperInvalidFile() {
        let input = [("1", "/nonexistent/file.jpg")]
        let results = StreamTestHarness.runMapper(PhotoMapper.self, input: input)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    func testPhotoMapperNonImage() {
        let input = [("1", "/some/text/file.txt")]
        let results = StreamTestHarness.runMapper(PhotoMapper.self, input: input)
        
        XCTAssertTrue(results.isEmpty)
    }


    func testPhotoReducerEmptyInput() {
        let input: [(UInt16, [String])] = []
        let results = StreamTestHarness.runReducer(PhotoReducer.self, input: input)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    // no emissions because only one group
    func testPhotoReducerSingleImage() {
        let input = [(UInt16(1), ["image1.jpg|abcdef1234567890"])]
        let results = StreamTestHarness.runReducer(PhotoReducer.self, input: input)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    // test reducer with duplicate images (should be grouped)
    func testPhotoReducerDuplicateImages() {
        let input = [(UInt16(1), [
            "image1.jpg|abcdef1234567890",
            "image2.jpg|abcdef1234567891",
            "image3.jpg|fedcba0987654321"
        ])]
        
        let results = StreamTestHarness.runReducer(PhotoReducer.self, input: input)
        
        XCTAssertEqual(results.count, 1)
        let result = results.first!
        XCTAssertEqual(result.key, 0)
        XCTAssertTrue(result.value.contains("image1.jpg"))
        XCTAssertTrue(result.value.contains("image2.jpg"))
        XCTAssertFalse(result.value.contains("image3.jpg"))
    }
    
    func testPhotoReducerInvalidFormat() {
        let input = [(UInt16(1), [
            "invalid_format_line",
            "image2.jpg|abcdef1234567890"
        ])]
        
        let results = StreamTestHarness.runReducer(PhotoReducer.self, input: input)
        
        XCTAssertTrue(results.isEmpty)
    }
}