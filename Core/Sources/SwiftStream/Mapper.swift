//
//  Mapper.swift
//  SwiftStream
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation

public protocol Mapper {
    // Helpful source: https://medium.com/globant/swift-generics-and-associated-types-73aa2b184c7a
    // associated types are sort of like generics but for protocols
    // we want to use CustomStringConvertible since we interface with Hadoop via standard I/O operations
    associatedtype KOut: CustomStringConvertible
    associatedtype VOut: CustomStringConvertible
    
    // serves like the setup() function in Java MapReduce
    init()
    // standard map() function in MapReduce
    func map(key: String, value: String, ctx: Context<KOut, VOut>)
}

