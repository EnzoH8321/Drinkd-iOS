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
                ""
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
        let hash = key.md5Hash()
        let url = diskPath.appending(path: "\(hash).\(ext)")
        return url.path()
    }

}

//MARK: Get Data from Caches
extension YelpCache {

    // True if we can use in memory cache, false if we cant
    private func getDataFromMemCache(key: NSString) -> Data? {
        guard let cacheableValue = nsCache.object(forKey: key) else { return nil }

        guard isFresh(value: cacheableValue) else { return nil }

        return cacheableValue.data
    }

    private func getDataFromDiskCache(key: String, ext: String) throws -> Data? {
        let path = createDiskPath(key: key, ext: ext)
        guard let data = fileManager.contents(atPath: path) else {  return nil }
        let cacheableValue = try JSONDecoder().decode(CacheableObject.self, from: data)
        guard isFresh(value: cacheableValue) else { return nil }
        return cacheableValue.data
    }

    // Use cached data if possible
    // Determine based on if cached data exists AND the time interval is less than 24 hours
    // Key determines the value
    // return Data if we can use cached data
    func useCachedData(forKey: NSString, dataType: YelpCache.DataType) -> Data? {
        // Try to use in memory cache
        if let inMemoryData = getDataFromMemCache(key: forKey) { return inMemoryData }

        do {
            // Try to use on disk cache
            if let onDiskData = try getDataFromDiskCache(key: forKey as String, ext: dataType.fileExt) { return onDiskData }
        } catch {
            Log.error.log("Error using the on disk cache: \(error)")
            return nil
        }

        return nil
    }
}

// MARK: Add CacheableObject to Caches
extension YelpCache {

    private func addToMemoryCache(obj: CacheableObject, key: NSString) {
        nsCache.setObject(obj, forKey: key)
    }

    private func addToDiskCache(obj: CacheableObject, key: String, ext: String) throws {
        let encodedData = try JSONEncoder().encode(obj)
        let path = createDiskPath(key: key, ext: ext)
        let result = fileManager.createFile(atPath: path, contents: encodedData)
        if !result { throw FileManagerErrors.unableToCreateFile(atPath: path)}
    }

    func addObjectToCache(data: Data, key: NSString, type: YelpCache.DataType) throws {
        let cacheObj = CacheableObject(timestamp: Date(), data: data)
        addToMemoryCache(obj: cacheObj, key: key)
        try addToDiskCache(obj: cacheObj, key: key as String, ext: type.fileExt)
    }

}


