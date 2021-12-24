//
//  Errors.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/23/21.
//

import Foundation

enum NetworkErrors: Error {
	case serializationError
	case decodingError
	case noUserLocationFoundError
	case invalidURLError
	case noURLFoundError
	case generalNetworkError
}

enum NetworkSuccess {
	case connectionSuccess
}
