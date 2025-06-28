//
//  Errors.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/23/21.
//

import Foundation

enum NetworkErrors:  String ,LocalizedError {
	case serializationError
	case decodingError
	case noUserLocationFoundError
	case invalidURLError
	case noURLFoundError
	case generalNetworkError
	case databaseRefNotFoundError

    var errorDescription: String? {
        return self.rawValue
    }
}

enum NetworkSuccess {
	case connectionSuccess
}
