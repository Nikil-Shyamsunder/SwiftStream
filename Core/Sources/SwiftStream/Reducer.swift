//
//  Reducer.swift
//  SwiftStream
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation

public protocol Reducer {
    // the input keys must be Equatable in order for us to group them
    associatedtype KIn: LosslessStringConvertible & Equatable
    associatedtype VIn: LosslessStringConvertible
    associatedtype KOut: CustomStringConvertible
    associatedtype VOut: CustomStringConvertible
    
    init()
    func reduce(key: KIn, values: AnyIterator<VIn>, ctx: Context<KOut, VOut>)
}
