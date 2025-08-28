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

    public var errorDescription: String? {
        switch self {
        case .missingProperty(let string):
            return "missingProperty error - \(string)"
        case .invalidHTTPStatus(let string):
            return "invalidHTTPStatus error - \(string)"
        }
    }
}
