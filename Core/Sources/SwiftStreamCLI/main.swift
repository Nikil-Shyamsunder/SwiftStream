//
//  main.swift
//  SwiftStreamCLI
//
//  Copyright Nikil Shyamsunder 2025
//

@main
struct SwiftStreamCLI {
    static func main() {
        do {
            let args = try CLIArguments(args: CommandLine.arguments)
            
            switch args.mode.lowercased() {
            case "map":
                try runMapper(typeName: args.type)
            case "reduce":
                try runReducer(typeName: args.type)
            default:
                throw CLIError.invalidMode("Mode must be 'map' or 'reduce'")
            }
        } catch {
            fputs("Error: \(error)\n", stderr)
            exit(1)
        }
    }
    
    static func runMapper(typeName: String) throws {
        switch typeName {
        case "WordCountMapper":
            try StreamProcessor.processStandardInput(using: WordCountMapper.self)
        default:
            throw CLIError.typeNotFound("Mapper type '\(typeName)' not found")
        }
    }
    
    static func runReducer(typeName: String) throws {
        switch typeName {
        case "WordCountReducer":
            try StreamProcessor.processStandardInput(using: WordCountReducer.self)
        default:
            throw CLIError.typeNotFound("Reducer type '\(typeName)' not found")
        }
    }
}

enum CLIError: Error {
    case missingRequiredArgument(String)
    case invalidMode(String)
    case typeNotFound(String)
    case packageLoadError(String)
}

struct CLIArguments {
    let mode: String
    let type: String
    let package: String?
    
    init(args: [String]) throws {
        var mode: String?
        var type: String?
        var package: String?
        
        var i = 1
        while i < args.count {
            switch args[i] {
            case "--mode":
                guard i + 1 < args.count else {
                    throw CLIError.missingRequiredArgument("--mode requires a value")
                }
                mode = args[i + 1]
                i += 2
            case "--type":
                guard i + 1 < args.count else {
                    throw CLIError.missingRequiredArgument("--type requires a value")
                }
                type = args[i + 1]
                i += 2
            case "--package":
                guard i + 1 < args.count else {
                    throw CLIError.missingRequiredArgument("--package requires a value")
                }
                package = args[i + 1]
                i += 2
            default:
                i += 1
            }
        }
        
        guard let m = mode else {
            throw CLIError.missingRequiredArgument("--mode is required")
        }
        guard let t = type else {
            throw CLIError.missingRequiredArgument("--type is required")
        }
        
        self.mode = m
        self.type = t
        self.package = package
    }
}
