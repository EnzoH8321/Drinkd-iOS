//
//  Errors.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 8/28/25.
//

import Foundation

enum YelpErrors: LocalizedError, Codable {
    case missingProperty(String)
    case invalidHTTPStatus(String)

     var errorDescription: String? {
        switch self {
        case .missingProperty(let string):
            return "missingProperty error - \(string)"
        case .invalidHTTPStatus(let string):
            return "invalidHTTPStatus error - \(string)"
        }
    }
}


enum LocationErrors: LocalizedError, Codable, Equatable {

    case invalidLastKnownLocation(msg: String, file: String = #file, line: Int = #line)

    var errorDescription: String? {
        switch self {
        case .invalidLastKnownLocation(let msg, let file, let line):
            Log.error.log(msg, file: file  , line: line)
            return "Invalid last known location - \(msg)"
        }
    }
}

enum UserDefaultsErrors: LocalizedError, Codable {

    case noUserID(msg: String, file: String = #file, line: Int = #line)

    var errorDescription: String? {
        switch self {
        case .noUserID(let msg, let file, let line):
            Log.error.log(msg, file: file, line: line)
            return "Unable to find UserID - \(msg)"
        }
    }
}

enum CachingErrors: LocalizedError, Codable {
    case unableToFindObjectWithKey(key: String)
    case unableToUseCachedData(forKey: String)

    var errorDescription: String? {
        switch self {
        case .unableToFindObjectWithKey(let key):
            return "Unable to find object with key: \(key)"
        case .unableToUseCachedData(forKey: let forKey):
            return "Unable to use cached data for key: \(forKey)"
        }
    }
}

enum FileManagerErrors: LocalizedError, Codable {
    case unableToCreateFile(atPath: String)
    case unableToRetrieveDataFromFile(atPath: String)

    var errorDescription: String {
        switch self {
        case .unableToCreateFile(let path):
            return "Unable to create file at path: \(path)"
        case .unableToRetrieveDataFromFile(atPath: let withPath):
            return "Unable to retrieve data from file at path: \(withPath)"
        }
    }
}
