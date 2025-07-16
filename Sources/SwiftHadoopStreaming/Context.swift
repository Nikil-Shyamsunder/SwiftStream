import Foundation

// MARK: - Context Objects for Emitting Output and Counters

public class StreamingContext {
    private var outputBuffer: String = ""

    public func emit<K: CustomStringConvertible, V: CustomStringConvertible>(key: K, value: V) {
        // Default Hadoop Streaming delimiter is tab '\t'
        // Newline '\n' is the record separator
        outputBuffer.append("\(key)\t\(value)\n")
    }

    // TODO: add methods for counters here later (if needed)

    func flush() {
        if !outputBuffer.isEmpty {
            FileHandle.standardOutput.write(Data(outputBuffer.utf8))
            outputBuffer = ""
        }
    }
}

public class MapperContext: StreamingContext {
    // TODO: Any Mapper-specific extensions
}

public class ReducerContext: StreamingContext {
    // Reducer-specific extensions
} 