//
//  Errors.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 8/28/25.
//

import Foundation

protocol AppError: LocalizedError, Codable {
    var errorDescription: String { get }
}

enum YelpErrors: AppError {
    case missingProperty(_ msg: String, file: String = #file, line: Int = #line)
    case invalidHTTPStatus(_ msg: String, file: String = #file, line: Int = #line)

     var errorDescription: String {
        switch self {
        case .missingProperty(let msg, let file, let line):
            Log.error.log(msg, file: file, line: line)
            return "missingProperty error - \(msg)"
        case .invalidHTTPStatus(let msg, let file, let line):
            Log.error.log(msg, file: file, line: line)
            return "invalidHTTPStatus error - \(msg)"
        }
    }
}

enum LocationErrors: AppError {

    case invalidLastKnownLocation(_ msg: String, file: String = #file, line: Int = #line)

    var errorDescription: String {
        switch self {
        case .invalidLastKnownLocation(let msg, let file, let line):
            Log.error.log(msg, file: file, line: line)
            return "Invalid last known location - \(msg)"
        }
    }
}

enum UserDefaultsErrors: AppError {

    case noUserID(_ msg: String, file: String = #file, line: Int = #line)

    var errorDescription: String {
        switch self {
        case .noUserID(let msg, let file, let line):
            Log.error.log(msg, file: file, line: line)
            return "Unable to find UserID - \(msg)"
        }
    }
}

enum CachingErrors: AppError {
    case unableToFindObjectWithKey(_ key: String, file: String = #file, line: Int = #line)
    case unableToUseCachedData(forKey: String, file: String = #file, line: Int = #line)

    var errorDescription: String {
        switch self {
        case .unableToFindObjectWithKey(let key, let file, let line):
            Log.error.log(key, file: file, line: line)
            return "Unable to find object with key: \(key)"
        case .unableToUseCachedData(let forKey, let file, let line):
            Log.error.log(forKey, file: file, line: line)
            return "Unable to use cached data for key: \(forKey)"
        }
    }
}

enum FileManagerErrors: AppError {
    case unableToCreateFile(atPath: String, file: String = #file, line: Int = #line)
    case unableToRetrieveDataFromFile(atPath: String, file: String = #file, line: Int = #line)

    var errorDescription: String {
        switch self {
        case .unableToCreateFile(let atPath, let file, let line):
            Log.error.log(atPath, file: file, line: line)
            return "Unable to create file at path: \(atPath)"
        case .unableToRetrieveDataFromFile(let atPath,  let file, let line):
            Log.error.log(atPath, file: file, line: line)
            return "Unable to retrieve data from file at path: \(atPath)"
        }
    }
}
