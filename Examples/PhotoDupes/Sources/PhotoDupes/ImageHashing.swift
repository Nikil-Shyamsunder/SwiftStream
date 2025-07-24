//
//  ImageHashing.swift
//  PhotoDupes
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
import ImageIO
#endif

public enum ImageHashingError: Error {
    case cannotLoadImage
    case cannotCreateGrayscale
    case invalidImageData
    case unsupportedPlatform
}

// Implement dhash algorithm for image hashing
//   dHash finds images that look similar to humans, even if they're:
//   - Different file sizes (1MB vs 5MB)
//   - Different resolutions (1024×768 vs 4096×3072)
//   - Slightly different colors/brightness
//   - Different formats (JPEG vs PNG)
//   - Slightly cropped or rotated

public struct ImageHashing {
    
    public static func dHash(url: URL) throws -> UInt64 {
        #if canImport(CoreGraphics)
        return try dHashCoreGraphics(url: url)
        #else
        throw ImageHashingError.unsupportedPlatform
        #endif
    }
    
    // use the hamming distance to compare two hashes
    public static func hamming(_ hash1: UInt64, _ hash2: UInt64) -> Int {
        let xor = hash1 ^ hash2
        return xor.nonzeroBitCount
    }
    
    #if canImport(CoreGraphics)
    private static func dHashCoreGraphics(url: URL) throws -> UInt64 {
        // Load the image into a format-agnostic representation
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
            // if its a gif, we only take the first frame  
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw ImageHashingError.cannotLoadImage
        }
        
        // Want to convert to grayscale, resize to 9x8 and compute hash
        let width = 9
        let height = 8
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bytesPerPixel = 1
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            throw ImageHashingError.cannotCreateGrayscale
        }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else {
            throw ImageHashingError.invalidImageData
        }
        
        let pixels = data.bindMemory(to: UInt8.self, capacity: width * height)
        
        // actually compute the hash
        var hash: UInt64 = 0
        for y in 0..<height {
            for x in 0..<(width - 1) {
                let leftPixel = pixels[y * width + x]
                let rightPixel = pixels[y * width + x + 1]
                
                if leftPixel < rightPixel {
                    let bitIndex = y * (width - 1) + x
                    hash |= (1 << bitIndex)
                }
            }
        }
        
        return hash
    }
    #endif
}