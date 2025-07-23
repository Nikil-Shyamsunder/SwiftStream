//
//  MapperContext.swift
//  SwiftStream
//
//  Created by Nikil Shyamsunder 2025
//

import Foundation

// Genericize the MapperContext to any Key-Value pair, as long as they can be converted to strings
public class MapperContext<KOut: CustomStringConvertible, VOut: CustomStringConvertible> {
    // the file handle should be constant
    private let outputHandle: FileHandle
    
    // counter serves as a debugging tool for distributed processing,
    // and same with the status
    private var counters: [String: [String: Int]] = [:]
    private var status: String = ""
    
    public init(outputHandle: FileHandle){
        self.outputHandle = outputHandle
    }
    
    // https://stackoverflow.com/questions/39627106/why-do-i-need-underscores-in-swift
    // TODO: I'm not forcing callable function parameters right now, but maybe would be nice in the future
    public func emit(_ key: KOut, _ value: VOut){
        // Hadoop streaming uses tabs by default
        // Swift String Interpolation: https://www.hackingwithswift.com/read/0/5/string-interpolation
        let line = "\(key)\t\(value)\n"
        
        // Swift byte buffer: https://developer.apple.com/documentation/foundation/data
        // FileHandle type works with buffers and buffering reduces system calls
        if let data = line.data(using: .utf8) {
            outputHandle.write(data)
        }
    }
    
    public func getCounters() -> [String: [String: Int]] {
            return counters
    }

    public func incrementCounter(group: String, name: String, by amount: Int = 1) {
        // if we don't have the group yet
        if counters[group] == nil {
            // [:] is an empty dictionary, type is inferred based on the type declaration when counters is declared
            counters[group] = [:]
        }
        counters[group]![name, default: 0] += amount
        
        // log the result
        let counterLine = "reporter:counter:\(group),\(name),\(amount)\n"
        if let data = counterLine.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
    
    public func setStatus(_ newStatus: String) {
        // simple setter + logging
        self.status = newStatus
        let statusLine = "reporter:status:\(newStatus)\n"
        if let data = statusLine.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
}
