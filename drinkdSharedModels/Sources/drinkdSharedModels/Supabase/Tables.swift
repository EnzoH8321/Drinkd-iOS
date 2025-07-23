
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

    public func decode(from data: Data) throws -> [any SupaBaseTable] {
        switch self {
        case .parties:
            return try JSONDecoder().decode([PartiesTable].self, from: data)
        case .users:
            return try JSONDecoder().decode([UsersTable].self, from: data)
        case .messages:
            return try JSONDecoder().decode([MessagesTable].self, from: data)
        case .ratedRestaurants:
            return try JSONDecoder().decode([RatedRestaurantsTable].self, from: data)
        }
    }
}

public protocol SupaBaseTable {

}


// For tables
public struct PartiesTable: Codable, Sendable, SupaBaseTable {
    public let id: UUID
    public let date_created: String
    public let party_leader: UUID
    public let code: Int
    public let party_name: String
    // Yelp URL
    public let restaurants_url: String?

    public init(id: UUID, party_name: String ,party_leader: UUID, date_created: String, code: Int, restaurants_url: String) {
        self.id = id
        self.party_leader = party_leader
        self.date_created = date_created
        self.code = code
        self.restaurants_url = restaurants_url
        self.party_name = party_name
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.date_created = try container.decode(String.self, forKey: .date_created)
        self.party_leader = try container.decode(UUID.self, forKey: .party_leader)
        self.code = try container.decode(Int.self, forKey: .code)
        self.party_name = try container.decode(String.self, forKey: .party_name)
        self.restaurants_url = try container.decode(String.self, forKey: .restaurants_url)
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
