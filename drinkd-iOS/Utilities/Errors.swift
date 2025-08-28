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


enum LocationErrors: LocalizedError, Codable {

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

//enum NetworkingErrors: LocalizedError, Codable {
//    case invalidURL(msg: String, location: CodeLocation = CodeLocation(file: #file, line: #line))
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL(let msg, let location):
//            Log.error.log(msg, file: location.file, line: location.line)
//            return "Invalid URL - \(msg)"
//        }
//    }
//}
