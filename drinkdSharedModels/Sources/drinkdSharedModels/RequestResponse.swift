//
//  Requests.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/7/25.
//
import Foundation

// For Client -> Vapor Server & vice versa

public enum PostRequestTypes {
    case createParty
    case joinParty
    case leaveParty
    case sendMessage
    case updateRating
}

public enum GetRequestTypes {
    case topRestaurants
}

public protocol PartyRequest {

}

// Requests are Client - Server
// Request to create a party
public struct CreatePartyRequest: Codable, PartyRequest {
    public let username: String
    public let userID: UUID

    public init(username: String, userID: UUID) {
        self.username = username
        self.userID = userID
    }
}


public struct JoinPartyRequest: Codable, PartyRequest {
    public let username: String
    public let partyCode: Int

    public init(username: String, partyCode: Int) {
        self.username = username
        self.partyCode = partyCode
    }
}

public struct LeavePartyRequest: Codable, PartyRequest  {
    public let userID: UUID

    public init(userID: UUID) {
        self.userID = userID
    }
}


public struct SendMessageRequest: Codable, PartyRequest {
    public let userID: UUID
    public let partyID: UUID
    public let message: String

    public init(userID: UUID, partyID: UUID, message: String) {
        self.userID = userID
        self.partyID = partyID
        self.message = message
    }
}

public struct UpdateRatingRequest: Codable, PartyRequest {
    public let partyID: UUID
    public let userID: UUID
    public let userName: String
    public let restaurantName: String
    public let rating: Int

   public init(partyID: UUID, userID: UUID, userName: String, restaurantName: String, rating: Int) {
        self.partyID = partyID
        self.userID = userID
        self.userName = userName
        self.restaurantName = restaurantName
        self.rating = rating
    }
}

public struct TopRestaurantsRequest: Codable, PartyRequest {
    public let partyID: UUID

    public init(partyID: UUID) {
        self.partyID = partyID
    }
}

// Used on the client, response from the server


public struct PostRouteResponse: Codable {
    public let currentUserName: String
    public let currentUserID: UUID
    public let currentPartyID: UUID

    public init(currentUserName: String, currentUserID: UUID, currentPartyID: UUID) {
        self.currentUserName = currentUserName
        self.currentUserID = currentUserID
        self.currentPartyID = currentPartyID
    }
}

public struct TopRestaurantResponse: Codable {
    public let restaurants: [RatedRestaurantsTable]

    public init(restaurants: [RatedRestaurantsTable]) {
        self.restaurants = restaurants
    }
}
