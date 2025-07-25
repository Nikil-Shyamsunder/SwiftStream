# SwiftStream

SwiftStream is a Swift framework that provides native MapReduce programming for Hadoop Streaming. Instead of writing shell scripts and managing STDIN/STDOUT manually, developers implement clean Swift protocols while the framework handles all I/O, error reporting, and Hadoop integration.

## Overview

Traditional Hadoop Streaming requires developers to manage low-level details like tab-separated output, counter reporting, and process communication. SwiftStream abstracts these concerns behind familiar Swift interfaces, allowing you to focus on business logic while maintaining full compatibility with Hadoop clusters.

The framework includes a complete example application that finds duplicate images using perceptual hashing, demonstrating real-world binary data processing in a distributed environment.

## Directory Structure

```
swiftstream/
├── Core/                           # SwiftStream framework
│   ├── Sources/SwiftStream/        # Core protocols and contexts
│   ├── Sources/SwiftStreamCLI/     # Command-line harness
│   └── Tests/SwiftStreamTests/     # Framework unit tests
├── Examples/
│   └── PhotoDupes/                 # Image duplicate detection example
│       ├── Sources/PhotoDupes/     # Mapper and reducer implementations
│       └── Tests/PhotoDupesTests/  # Example unit tests
├── docker/                         # Hadoop + Swift container
├── scripts/                        # Build and utility scripts
└── docs/                          # Additional documentation
```

## End-to-End WordCount Example
See [EXAMPLE.md](https://github.com/Nikil-Shyamsunder/SwiftStream/blob/main/EXAMPLE.md) for a full example of building the WordCount example in Swift, compiling it in Linux, and running it with Hadoop Streaming on a Docker image.

## Core Framework

SwiftStream provides two main protocols that abstract MapReduce operations:

```swift
public protocol Mapper {
    associatedtype KOut: CustomStringConvertible
    associatedtype VOut: CustomStringConvertible
    
    init()
    func map(key: String, value: String, ctx: MapperContext<KOut, VOut>)
}

public protocol Reducer {
    associatedtype KIn: LosslessStringConvertible & Equatable
    associatedtype VIn: LosslessStringConvertible
    associatedtype KOut: CustomStringConvertible
    associatedtype VOut: CustomStringConvertible
    
    init()
    func reduce(key: KIn, values: AnyIterator<VIn>, ctx: ReducerContext<KOut, VOut>)
}
```

The context objects handle output emission, Hadoop counter reporting, and status updates. This design ensures your mapper and reducer logic remains testable and independent of I/O concerns.

## Building and Testing

Build the core framework:
```bash
cd Core
swift build
swift test
```

Build the PhotoDupes example:
```bash
cd Examples/PhotoDupes
swift build
swift test
```

For containerized builds with Hadoop integration:
```bash
./scripts/build-image.sh
```

## Using SwiftStream for Your Own Applications

### 1. Implement Your Mapper

```swift
struct MyMapper: Mapper {
    typealias KOut = String
    typealias VOut = Int
    
    init() {}
    
    func map(key: String, value: String, ctx: MapperContext<String, Int>) {
        // Your processing logic here
        let processedValue = processInput(value)
        ctx.emit(processedValue.key, processedValue.count)
        ctx.incrementCounter(group: "MyApp", name: "records_processed", by: 1)
    }
}
```

### 2. Implement Your Reducer

```swift
struct MyReducer: Reducer {
    typealias KIn = String
    typealias VIn = Int
    typealias KOut = String
    typealias VOut = Int
    
    init() {}
    
    func reduce(key: String, values: AnyIterator<Int>, ctx: ReducerContext<String, Int>) {
        let total = values.reduce(0, +)
        ctx.emit(key, total)
    }
}
```

### 3. Create CLI Integration

Add your mapper and reducer to the CLI harness or create a separate executable that uses `StreamProcessor.processStandardInput()` to handle Hadoop Streaming integration.

### 4. Test with StreamTestHarness

```swift
let results = StreamTestHarness.runMapper(MyMapper.self, 
                                        input: [("key1", "test data")])
XCTAssertEqual(results.count, 1)
```

## Word Count Example

The framework includes a basic word count implementation in the CLI harness:

```swift
struct WordCountMapper: Mapper {
    typealias KOut = String
    typealias VOut = Int
    
    func map(key: String, value: String, ctx: MapperContext<String, Int>) {
        let words = value.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        for word in words {
            ctx.emit(word, 1)
        }
    }
}

struct WordCountReducer: Reducer {
    typealias KIn = String
    typealias VIn = Int
    typealias KOut = String
    typealias VOut = Int
    
    func reduce(key: String, values: AnyIterator<Int>, ctx: ReducerContext<String, Int>) {
        let total = values.reduce(0, +)
        ctx.emit(key, total)
    }
}
```

## A More Complex Case: PhotoDupes --- Duplicate Image Detection

The PhotoDupes example demonstrates advanced binary data processing by finding visually similar images using perceptual hashing. This application showcases real-world MapReduce patterns for content analysis.

### Algorithm Overview

The mapper computes a 64-bit dHash (difference hash) for each image by resizing it to 9x8 pixels, converting to grayscale, and encoding horizontal brightness gradients. Images are grouped by the top 16 bits of their hash to distribute processing across reducers.

The reducer performs clustering within each hash group by comparing full 64-bit hashes using Hamming distance. Images with distance ≤ 4 are considered duplicates and grouped into connected components.

### Running PhotoDupes

Generate a manifest of image files:
```bash
./scripts/generate-manifest.sh /path/to/photos photos.manifest
```

Run locally for testing:
```bash
cd Examples/PhotoDupes
./.build/debug/photodupes local-test ../../photos.manifest
```

Run with Hadoop Streaming:
```bash
docker run --rm -v $PWD:/data swift:hadoop \
    hadoop-job /data/photos.manifest /data/output
```

The output contains CSV-formatted duplicate groups:
```
0,/photos/image1.jpg,/photos/image1_copy.jpg
1,/photos/vacation1.jpg,/photos/vacation1_edited.jpg,/photos/vacation1_small.jpg
```

### Technical Implementation

PhotoMapper extracts perceptual hashes and emits hash prefixes for distribution:
```swift
let hash = try ImageHashing.dHash(url: fileURL)
let prefix = UInt16(hash >> 48)
ctx.emit(prefix, "\(filePath)|\(String(hash, radix: 16))")
```

PhotoReducer performs connected component clustering:
```swift
for i in photos.indices {
    guard !visited.contains(i) else { continue }
    
    visited.insert(i)
    var cluster = [photos[i].0]
    
    for j in photos.indices where j > i && !visited.contains(j) {
        let hammingDistance = ImageHashing.hamming(photos[i].1, photos[j].1)
        if hammingDistance <= hammingThreshold {
            visited.insert(j)
            cluster.append(photos[j].0)
        }
    }
    
    if cluster.count > 1 {
        ctx.emit(groupId, cluster.joined(separator: ","))
        groupId += 1
    }
}
```

## Deployment

The included Docker configuration provides a complete Hadoop Streaming environment with Swift and all necessary dependencies. The container can be deployed to any Hadoop cluster that supports Streaming jobs.
