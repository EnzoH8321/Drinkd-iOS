//
//  Cache.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 11/7/25.
//

import Foundation
import drinkdSharedModels

// NSCache requires this to be a class
class CacheableValue: NSDiscardableContent {

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

    private var nsCache: NSCache<NSString, CacheableValue>

    init(nsCache: NSCache<NSString, CacheableValue>) {
        self.nsCache = nsCache
        super.init()
        nsCache.delegate = self
    }

    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        // Handle pre eviction
        Log.general.log("Evicting Obj - \(obj)")
    }


    func addObject(data: Data, key: NSString) throws {
        let cacheValue = CacheableValue(timestamp: Date(), data: data)
        nsCache.setObject(cacheValue, forKey: key)

        // Check if the object was successfully added to the cache
        guard nsCache.object(forKey: key) != nil else { throw CachingErrors.unableToFindObjectWithKey(key as String) }
    }

    func getImage(urlAsKey: NSString) throws -> Data {
        guard let object = nsCache.object(forKey: urlAsKey) else { throw CachingErrors.unableToFindObjectWithKey(urlAsKey as String) }
        return object.data
    }

    func getBusinessSearch(locationAsKey: NSString) throws -> YelpApiBusinessSearch  {
        guard let object = nsCache.object(forKey: locationAsKey) else {throw CachingErrors.unableToFindObjectWithKey("\(locationAsKey)")}
        return try JSONDecoder().decode(YelpApiBusinessSearch.self, from: object.data)
    }

    // True if value is fresh (fresh meaning the data is less than 24 hours)
    // We do not need to make another network request if data is fresh
    private func isFresh(value: CacheableValue) -> Bool {
        let timeInterval =  abs(Date.now.timeIntervalSince(value.timestamp))
        return timeInterval < 86400 ? true : false
    }

    // Use cached data if possible
    // Determine based on if cached data exists AND the time interval is less than 24 hours
    // Key determines the value
    // return True if we should used cached data
    func useCachedData(forKey: NSString) -> Bool {
        guard let object = nsCache.object(forKey: forKey) else { return false }
        let isFresh = isFresh(value: object) ? true : false
        Log.general.log("\(isFresh ? "Using" : "Not using" ) cached data for key: \(forKey)")
        return isFresh

    }

    /// Converts coordinates to a cache key rounded to 4 decimal places (~11m precision).
    /// We use this precision level in order to ensure a certain consistency, more precise values are too volatile and not reliable to use as a key
    /// Format: "latitude+longitude" (e.g., "37.7749/-122.4194")
    func convertLocationToKey(latitude: Double, longitude: Double) -> NSString {
        let roundedLatitude = round(latitude * 10000) / 10000
        let roundedLongitude = round(longitude * 10000) / 10000
        return "\(roundedLatitude)/\(roundedLongitude)" as NSString
    }
}

