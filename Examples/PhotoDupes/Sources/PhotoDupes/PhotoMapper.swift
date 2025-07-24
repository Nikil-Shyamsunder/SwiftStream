//
//  PhotoMapper.swift
//  PhotoDupes
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation
import SwiftStream

public struct PhotoMapper: Mapper {
    public typealias KOut = UInt16
    public typealias VOut = String
    
    public init() {}
    
    // Calculates the hash from the file path
    // emits the prefix (top 16 bits of the hash) and the full hash
    public func map(key: String, value: String, ctx: MapperContext<UInt16, String>) {
        let filePath = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileURL = URL(fileURLWithPath: filePath)
        
        // only accept proper image files
        guard fileURL.pathExtension.lowercased() == "jpg" ||
              fileURL.pathExtension.lowercased() == "jpeg" ||
              fileURL.pathExtension.lowercased() == "png" ||
              fileURL.pathExtension.lowercased() == "heic" else {
            ctx.incrementCounter(group: "PhotoDupes", name: "skipped_non_image", by: 1)
            return
        }
        
        guard FileManager.default.fileExists(atPath: filePath) else {
            ctx.incrementCounter(group: "PhotoDupes", name: "missing_file", by: 1)
            return
        }
        
        // calculate the hash, output the prefix and full hash
        do {
            let hash = try ImageHashing.dHash(url: fileURL)
            let prefix = UInt16(hash >> 48) // Top 16 bits
            let hashHex = String(hash, radix: 16)
            
            ctx.emit(prefix, "\(filePath)|\(hashHex)")
            ctx.incrementCounter(group: "PhotoDupes", name: "processed_images", by: 1)
            
        } catch {
            ctx.incrementCounter(group: "PhotoDupes", name: "corrupt_images", by: 1)
            
            switch error {
            case ImageHashingError.cannotLoadImage:
                ctx.incrementCounter(group: "PhotoDupes", name: "cannot_load", by: 1)
            case ImageHashingError.cannotCreateGrayscale:
                ctx.incrementCounter(group: "PhotoDupes", name: "cannot_process", by: 1)
            case ImageHashingError.invalidImageData:
                ctx.incrementCounter(group: "PhotoDupes", name: "invalid_data", by: 1)
            default:
                ctx.incrementCounter(group: "PhotoDupes", name: "unknown_error", by: 1)
            }
        }
    }
}