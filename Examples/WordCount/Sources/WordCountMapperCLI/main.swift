//
//  main.swift
//  WordCountMapperCLI
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation
import SwiftStream
import WordCount

@main
struct WordCountMapperCLI {
    static func main() {
        do {
            try StreamProcessor.processStandardInput(using: WordCountMapper.self)
        } catch {
            if let data = "Error: \(error)\n".data(using: .utf8) {
                try? FileHandle.standardError.write(contentsOf: data)
            }
            exit(1)
        }
    }
}