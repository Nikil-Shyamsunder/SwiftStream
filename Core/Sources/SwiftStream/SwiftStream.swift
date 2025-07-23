//
//  SwiftStream.swift
//  SwiftStream
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation

// https://reintech.io/blog/understanding-implementing-swifts-exported
// so that all files that import this file automatically get these APIs exported to them!
@_exported import struct Foundation.Data
@_exported import class Foundation.FileHandle

// in Swift, create an error type just by extending Error
public enum SwiftStreamError: Error {
    case invalidInput(String)
    case processingError(String)
    case reflectionError(String)
}

// Handles interfce between I/O streams and the MapReduce structures
public struct StreamProcessor {
    public static func processStandardInput<M: Mapper>(using mapperType: M.Type) throws {
        let context = Context<M.KOut, M.VOut>()
        let mapper = M()
        
        // read each line, split, call the mapper
        while let line = readLine() {
            let parts = line.components(separatedBy: "\t")
            let key = parts.first ?? ""
            let value = parts.count > 1 ? parts[1] : ""
            
            mapper.map(key: key, value: value, ctx: context)
        }
    }
    
    public static func processStandardInput<R: Reducer>(using reducerType: R.Type) throws {
        let context = Context<R.KOut, R.VOut>()
        let reducer = R()
        
        // optional value
        var currentKey: R.KIn?
        var currentValues: [R.VIn] = [] // empty if no asociated values, or key is None
        
        // read every line, group, and reduce
        while let line = readLine() {
            let parts = line.components(separatedBy: "\t")
            guard parts.count >= 2,
                  let key = R.KIn(parts[0]),
                  let value = R.VIn(parts[1]) else {
                continue
            }
            
            if let current = currentKey, current != key {
                let values = AnyIterator(currentValues.makeIterator())
                reducer.reduce(key: current, values: values, ctx: context)
                currentValues.removeAll()
            }
            
            currentKey = key
            currentValues.append(value)
        }
        
        // process final line
        if let key = currentKey {
            let values = AnyIterator(currentValues.makeIterator())
            reducer.reduce(key: key, values: values, ctx: context)
        }
    }
}
