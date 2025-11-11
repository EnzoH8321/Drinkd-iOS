//
//  Cache.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 11/7/25.
//

import Foundation
import drinkdSharedModels

// NSCache requires this to be a class
class CacheableObject: NSDiscardableContent, Codable {

    func beginContentAccess() -> Bool {
        return true
    }

    func endContentAccess() {

    }

    func discardContentIfPossible() {

    }

    func isContentDiscarded() -> Bool {
        return false
    }

    // Time in which this struct was created.
    var timestamp: Date
    // Data to be cached
    var data: Data

    init(timestamp: Date, data: Data) {
        self.timestamp = timestamp
        self.data = data
    }
}

@Observable
final class YelpCache: NSObject, NSCacheDelegate {

    enum DataType {
        case image
        case searchProperties

        var fileExt: String {
            switch self {
            case .image:
                // When using an image path as the key, the path should already have an extension
                "jpg"
            case .searchProperties:
                "txt"
            }
        }
    }

    private var nsCache: NSCache<NSString, CacheableObject>

    private var diskPath: URL {
        return URL.cachesDirectory
    }

    private var fileManager: FileManager {
        return FileManager.default
    }


    init(nsCache: NSCache<NSString, CacheableObject>) {
        self.nsCache = nsCache
        super.init()
        nsCache.delegate = self
    }

    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        // Handle pre eviction
        Log.general.log("Evicting Obj - \(obj)")
    }

    /// Check's how old the cached data is relative to now. If less than 24 hours old, we want to use the cached data
    /// - Returns: `true` if the cached data is less than 24 hours old, `false` otherwise
    private func isFresh(value: CacheableObject) -> Bool {
        let timeInterval =  abs(Date.now.timeIntervalSince(value.timestamp))
        return timeInterval < 86400 ? true : false
    }

    /// Converts coordinates to a cache key rounded to 4 decimal places (~11m precision).
    /// We use this precision level in order to ensure a certain consistency, more precise values are too volatile and not reliable to use as a key
    /// Format: "latitude+longitude" (e.g., "37.7749/-122.4194")
    func convertLocationToKey(latitude: Double, longitude: Double) -> NSString {
        let roundedLatitude = round(latitude * 10000) / 10000
        let roundedLongitude = round(longitude * 10000) / 10000
        return "\(roundedLatitude):\(roundedLongitude)" as NSString
    }

    /// Creates a file path on disk for caching based on a hashed key
    /// - Parameter key: The unique identifier for the cached item (will be hashed for the filename)
    /// - Parameter ext: The file extension to use for the cached file (e.g., "json", "png")
    /// - Returns: The complete file path as a String where the cached item will be stored
    private func createDiskPath(key: String, ext: String) -> String {
       return diskPath.appending(path: "\(key).\(ext)").path()
    }

}

//MARK: Get Data from Caches
extension YelpCache {

    /// Retrieves cached data from memory cache if it exists and is fresh
    /// - Parameter key: The unique identifier for the cached item
    /// - Returns: The cached `Data` if found and fresh (less than 24 hours old), `nil` otherwise
    private func getDataFromMemCache(key: NSString) -> Data? {
        guard let cacheableObj = nsCache.object(forKey: key), isFresh(value: cacheableObj) else { return nil }
        return cacheableObj.data
    }

    /// Retrieves cached data from disk cache if it exists and is fresh
    /// - Parameter key: The unique identifier for the cached item (will be hashed for the filename)
    /// - Parameter ext: The file extension of the cached file
    /// - Returns: The cached `Data` if found and fresh (less than 24 hours old), `nil` otherwise
    /// - Throws: `DecodingError` if the cached file cannot be decoded into a `CacheableObject`
    private func getDataFromDiskCache(key: String, ext: String) throws -> Data? {
        let path = createDiskPath(key: key, ext: ext)
        guard let data = fileManager.contents(atPath: path) else {  return nil }
        let cacheableValue = try JSONDecoder().decode(CacheableObject.self, from: data)
        guard isFresh(value: cacheableValue) else { return nil }
        return cacheableValue.data
    }

    /// Attempts to retrieve cached data from memory or disk cache
    /// - Parameter key: The unique identifier for the cached item
    /// - Parameter dataType: The type of data being cached (determines file extension)
    /// - Returns: The cached `Data` if found and fresh in either memory or disk cache, `nil` otherwise
    func useCachedData(key: NSString, dataType: YelpCache.DataType) -> Data? {
        let hash = key.md5Hash()

        // Try to use in memory cache
        if let inMemoryData = getDataFromMemCache(key: hash) { return inMemoryData }

        do {
            // Try to use on disk cache
            if let onDiskData = try getDataFromDiskCache(key: hash as String, ext: dataType.fileExt) { return onDiskData }
        } catch {
            Log.error.log("Error using the on disk cache: \(error)")
            return nil
        }

        return nil
    }
}

// MARK: Add CacheableObject to Caches
extension YelpCache {

    /// Adds a cacheable object to the in-memory cache
    /// - Parameter obj: The `CacheableObject` to store in memory (contains data and timestamp)
    /// - Parameter key: The unique identifier for the cached item (used as the cache lookup key)
    private func addToMemoryCache(obj: CacheableObject, key: NSString) {
        nsCache.setObject(obj, forKey: key)
    }

    /// Saves a cacheable object to disk storage
    /// - Parameter obj: The `CacheableObject` to cache (contains data and timestamp)
    /// - Parameter key: The unique identifier for the cached item (will be hashed for the filename)
    /// - Parameter ext: The file extension to use for the cached file
    /// - Throws: `EncodingError` if the object cannot be encoded to JSON, or `FileManagerErrors.unableToCreateFile` if the file cannot be written to disk
    private func addToDiskCache(obj: CacheableObject, key: String, ext: String) throws {
        let encodedData = try JSONEncoder().encode(obj)
        let path = createDiskPath(key: key, ext: ext)
        let result = fileManager.createFile(atPath: path, contents: encodedData)
        if !result { throw FileManagerErrors.unableToCreateFile(atPath: path)}
    }

    /// Adds data to both memory and disk caches with a timestamp
    /// - Parameter data: The raw data to cache
    /// - Parameter key: The unique identifier for the cached item
    /// - Parameter type: The type of data being cached (determines file extension)
    /// - Throws: `EncodingError` if the object cannot be encoded, or `FileManagerErrors.unableToCreateFile` if disk write fails
    func addObjectToCache(data: Data, key: NSString, type: YelpCache.DataType) throws {
        let hash = key.md5Hash()
        let cacheObj = CacheableObject(timestamp: Date(), data: data)
        addToMemoryCache(obj: cacheObj, key: hash)
        try addToDiskCache(obj: cacheObj, key: hash as String, ext: type.fileExt)
    }

}


