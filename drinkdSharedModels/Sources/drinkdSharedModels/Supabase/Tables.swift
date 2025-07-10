
//
//  Untitled.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/4/25.
//

import Foundation

public enum TableTypes {
    case parties
    case users
    case messages
    case ratedRestaurants

    public var tableName: String {
        switch self {
        case .parties:
            return "Parties"
        case .users:
            return "Users"
        case .messages:
            return "Messages"
        case .ratedRestaurants:
            return "RatedRestaurants"
        }
    }
}

public protocol SupaBaseTable {

}


// For tables
public struct PartiesTable: Codable, Sendable, SupaBaseTable {
    public let id: UUID?
    public let date_created: String?
    public let party_leader: UUID?
    public let code: Int?

    public init(id: UUID, partyLeader: UUID, date_created: String, code: Int) {
        self.id = id
        self.party_leader = partyLeader
        self.date_created = date_created
        self.code = code
    }
}

public struct UsersTable: Codable, Sendable, SupaBaseTable {
    public let id: UUID
    public let date_created: String
    public let username: String
    public let party_id: UUID

    public init(id: UUID, username: String, date_created: String, memberOfParty: UUID) {
        self.id = id
        self.username = username
        self.date_created = date_created
        self.party_id = memberOfParty
    }
}

public struct MessagesTable: Codable, Sendable, SupaBaseTable {
    public let id: UUID
    public let date_created: String
    public let party_id: UUID
    public let text: String
    public let user_id: UUID

    public init(id: UUID, partyId: UUID, date_created: String, text: String, userId: UUID) {
        self.id = id
        self.party_id = partyId
        self.date_created = date_created
        self.text = text
        self.user_id = userId
    }
}

public struct RatedRestaurantsTable: Codable, Sendable, SupaBaseTable, Hashable {
    public let id: UUID
    public let party_id: UUID
    public let user_id: UUID
    public let username: String
    public let restaurant_name: String
    public var rating: Int
    public var image_url: String
    // For Client, not used in Supabase
    public var imageData: Data?

    public init(id: UUID, partyID: UUID, userID: UUID, userName: String, restaurantName: String, rating: Int, imageURL: String, imageData: Data? = nil) {
       self.id = id
        self.party_id = partyID
        self.user_id = userID
        self.username = userName
        self.restaurant_name = restaurantName
        self.rating = rating
        self.image_url = imageURL
        self.imageData = imageData
    }
}
