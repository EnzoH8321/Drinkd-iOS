//
//  Networking.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/8/25.
//
import Foundation

public final class SharedNetworking {
    @MainActor public static let shared = SharedNetworking()
    private init() { }
}

public enum HTTP {
    case get(GetRoutes)
    case post(PostRoutes)
    case delete

    private var baseURLString: String { "http://127.0.0.1:8080/" }

    public enum PostRoutes: String, CaseIterable {
        case createParty
        case joinParty
        case leaveParty
        case sendMessage
        case updateRating

    }

    public enum GetRoutes: String, CaseIterable {
        case topRestaurants
        case rejoinParty
    }

    public var fullURLString: String {
        switch self {
        case .get(let getRoutes):
            return baseURLString + getRoutes.rawValue
        case .post(let postRoutes):
           return baseURLString + postRoutes.rawValue
        case .delete:
            return baseURLString
        }
    }
}
