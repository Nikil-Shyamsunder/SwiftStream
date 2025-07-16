import Foundation

// MARK: - Error Handling

public enum HadoopStreamingError: Error, CustomStringConvertible {
    case invalidInputFormat(line: String)
    case keyConversionFailed(value: String, targetType: String)
    case valueConversionFailed(value: String, targetType: String)
    case custom(message: String)

    public var description: String {
        switch self {
        case .invalidInputFormat(let line):
            return "Invalid input format: '\(line)'. Expected 'key\\tvalue'."
        case .keyConversionFailed(let value, let targetType):
            return "Failed to convert key '\(value)' to \(targetType)."
        case .valueConversionFailed(let value, let targetType):
            return "Failed to convert value '\(value)' to \(targetType)."
        case .custom(let message):
            return message
        }
    }
} 