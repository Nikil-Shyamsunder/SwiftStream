//
//  PhotoMapper.swift
//  PhotoReducer
//
//  Copyright Nikil Shyamsunder 2025
//

import Foundation
import SwiftStream

public struct PhotoReducer: Reducer {
    // the top 16 bits (prefix) of the hash 
    public typealias KIn = UInt16

    // {file path}|{full hash}
    public typealias VIn = String

    // group id for the duplicate set
    public typealias KOut = Int

    // comma separatexd list of file paths that are duplicates
    public typealias VOut = String
    
    private let hammingThreshold: Int
    
    public init() {
        self.hammingThreshold = 4
    }
    
    public func reduce(key: UInt16, values: AnyIterator<String>, ctx: Context<Int, String>) {
        // parse all of the values into a list of (file_path, full_hash)
        // log error if the format is incorrect
        let photos = Array(values).compactMap { line -> (String, UInt64)? in
            let components = line.split(separator: "|", maxSplits: 1)
            guard components.count == 2,
                  let hash = UInt64(String(components[1]), radix: 16) else {
                ctx.incrementCounter(group: "PhotoDupes", name: "invalid_format", by: 1)
                return nil
            }
            return (String(components[0]), hash)
        }
        
        guard !photos.isEmpty else { return }
        
        // basically undirected graph component clustering via depth-first search
        // where edges are defined by hamming distance < hammingThreshold
        var visited = Set<Int>()
        var groupId = 0
        
        for i in photos.indices {
            guard !visited.contains(i) else { continue }
            
            visited.insert(i)
            var cluster = [photos[i].0]
            
            // check all other photos for hamming distance
            // this is O(n^2) but since we pre-group by prefix, in theory it should be manageable
            for j in photos.indices where j > i && !visited.contains(j) {
                let hammingDistance = ImageHashing.hamming(photos[i].1, photos[j].1)
                if hammingDistance <= hammingThreshold {
                    visited.insert(j)
                    cluster.append(photos[j].0)
                }
            }
            
            // only emit if we have a cluster of duplicates
            if cluster.count > 1 {
                let clusterString = cluster.joined(separator: ",")
                ctx.emit(groupId, clusterString)
                ctx.incrementCounter(group: "PhotoDupes", name: "duplicate_groups", by: 1)
                ctx.incrementCounter(group: "PhotoDupes", name: "duplicate_images", by: cluster.count)
                groupId += 1
            }
        }
        
        ctx.incrementCounter(group: "PhotoDupes", name: "processed_buckets", by: 1)
        ctx.incrementCounter(group: "PhotoDupes", name: "total_photos_in_bucket", by: photos.count)
    }
}