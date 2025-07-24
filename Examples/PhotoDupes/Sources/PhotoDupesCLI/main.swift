//
//  main.swift
//  PhotoDupesCLI
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation
import SwiftStream
import PhotoDupes

enum PhotoDupesCLIError: Error {
    case invalidArguments
    case invalidMode(String)
    case fileNotFound(String)
}

@main
struct PhotoDupesCLI {
    static func main() {
        // Check if the user provided any arguments
        do {
            let args = CommandLine.arguments
            
            guard args.count >= 2 else {
                printUsage()
                exit(1)
            }
            
            let command = args[1]
            
            switch command {
            case "map":
                try StreamProcessor.processStandardInput(using: PhotoMapper.self)
            case "reduce":
                try StreamProcessor.processStandardInput(using: PhotoReducer.self)
            case "local-test":
                try runLocalTest(args: Array(args.dropFirst(2)))
            default:
                throw PhotoDupesCLIError.invalidMode("Unknown mode: \(command)")
            }
        } catch {
            fputs("Error: \(error)\n", stderr)
            exit(1)
        }
    }
    
    static func printUsage() {
        print("""
        Usage: PhotoDupes <command> [arguments]
        
        Commands:
          map                 Run in mapper mode (reads from stdin)
          reduce              Run in reducer mode (reads from stdin)
          local-test <file>   Run local test with manifest file
        """)
    }
    
    // Runs a local test with a manifest file
    // The manifest file should contain paths to image files, one per line
    // It will read the file, compute hashes, and print duplicate groups
    static func runLocalTest(args: [String]) throws {
        guard let manifestPath = args.first else {
            throw PhotoDupesCLIError.invalidArguments
        }
        
        guard FileManager.default.fileExists(atPath: manifestPath) else {
            throw PhotoDupesCLIError.fileNotFound(manifestPath)
        }
        
        print("Running local PhotoDupes test with manifest: \(manifestPath)")
        
        let manifestContent = try String(contentsOfFile: manifestPath)
        let lines = manifestContent.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
        
        let mapInput = lines.enumerated().map { (index, line) in
            return ("line\(index)", line)
        }
        
        print("Map phase: Processing \(mapInput.count) files...")
        let mapResults = StreamTestHarness.runMapper(PhotoMapper.self, input: mapInput)
        
        let reduceInput = Dictionary(grouping: mapResults, by: { $0.key })
            .mapValues { results in results.map { $0.value } }
            .map { (key, values) in (key, values) }
        
        print("Reduce phase: Processing \(reduceInput.count) hash buckets...")
        let reduceResults = StreamTestHarness.runReducer(PhotoReducer.self, input: reduceInput)
        
        print("\nResults:")
        print("Found \(reduceResults.count) duplicate groups:")
        for result in reduceResults {
            print("Group \(result.key): \(result.value)")
        }
        
        if reduceResults.isEmpty {
            print("No duplicate images found.")
        }
    }
}