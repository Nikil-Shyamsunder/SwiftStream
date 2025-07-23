//
//  StreamTestHarness.swift
//  SwiftStream
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation

// the StreamTestHarness allows for in-memory MapReduce testing without the need for Hadoop. Primarily swaps out the I/O plumbing while using the same code path for map and reduce
public class StreamTestHarness {
    
    public struct TestOutput<K: CustomStringConvertible, V: CustomStringConvertible> {
        public let key: K
        public let value: V
        
        public init(key: K, value: V) {
            self.key = key
            self.value = value
        }
    }
    
    public static func runMapper<M: Mapper>(
        _ mapperType: M.Type,
        input: [(String, String)]
    ) -> [TestOutput<M.KOut, M.VOut>] where M.KOut: LosslessStringConvertible, M.VOut: LosslessStringConvertible {
        // create an in-memory pipe (no file I/O)
        let pipe = Pipe()
        let context = Context<M.KOut, M.VOut>(outputHandle: pipe.fileHandleForWriting)
        let mapper = M()
        
        for (key, value) in input {
            mapper.map(key: key, value: value, ctx: context)
        }
        
        pipe.fileHandleForWriting.closeFile()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return parseOutput(output)
    }
    
    public static func runReducer<R: Reducer>(
        _ reducerType: R.Type,
        input: [(R.KIn, [R.VIn])]
    ) -> [TestOutput<R.KOut, R.VOut>] where R.KOut: LosslessStringConvertible, R.VOut: LosslessStringConvertible {
        let pipe = Pipe()
        let context = Context<R.KOut, R.VOut>(outputHandle: pipe.fileHandleForWriting)
        let reducer = R()
        
        for (key, valueList) in input {
            let values = AnyIterator(valueList.makeIterator())
            reducer.reduce(key: key, values: values, ctx: context)
        }
        
        pipe.fileHandleForWriting.closeFile()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return parseOutput(output)
    }
    
    private static func parseOutput<K: LosslessStringConvertible, V: LosslessStringConvertible>(
        _ output: String
    ) -> [TestOutput<K, V>] {
        let lines = output.components(separatedBy: .newlines).filter { !$0.isEmpty }
        return lines.compactMap { line in
            let parts = line.components(separatedBy: "\t")
            guard parts.count >= 2,
                  let key = K(parts[0]),
                  let value = V(parts[1]) else {
                return nil
            }
            return TestOutput(key: key, value: value)
        }
    }
}
