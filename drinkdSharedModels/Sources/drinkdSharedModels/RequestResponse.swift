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

public protocol PartyRequest {

}

// Requests are Client - Server
// Request to create a party
public struct CreatePartyRequest: Codable, PartyRequest {
    public let username: String
    public let userID: UUID
    public let restaurants_url: String
    public let partyName: String

    public init(username: String, userID: UUID, restaurants_url: String, partyName: String) {
        self.username = username
        self.userID = userID
        self.restaurants_url = restaurants_url
        self.partyName = partyName
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
    public let imageURL: String

    public init(partyID: UUID, userID: UUID, userName: String, restaurantName: String, rating: Int, imageURL: String) {
        self.partyID = partyID
        self.userID = userID
        self.userName = userName
        self.restaurantName = restaurantName
        self.rating = rating
        self.imageURL = imageURL
    }
}

// Used on the client, response from the server
public struct PostRouteResponse: Codable {
    public let currentUserName: String
    public let currentUserID: UUID
    public let currentPartyID: UUID
    public let partyName: String
    public let yelpURL: String

//    public init(currentUserName: String, currentUserID: UUID, currentPartyID: UUID) {
//        self.currentUserName = currentUserName
//        self.currentUserID = currentUserID
//        self.currentPartyID = currentPartyID
//    }

    public init(currentUserName: String, currentUserID: UUID, currentPartyID: UUID, partyName: String, yelpURL: String) {
        self.currentUserName = currentUserName
        self.currentUserID = currentUserID
        self.currentPartyID = currentPartyID
        self.partyName = partyName
        self.yelpURL = yelpURL
    }
}

public struct GetRouteResponse: Codable {
    public var restaurants: [RatedRestaurantsTable]?
    public let partyID: UUID?
    public let partyName: String?
    public let yelpURL: String?


    public init(restaurants: [RatedRestaurantsTable]? = nil, partyID: UUID?, partyName: String?, yelpURL: String?) {
        self.restaurants = restaurants
        self.partyID = partyID
        self.partyName = partyName
        self.yelpURL = yelpURL
    }


}

//public struct TopRestaurantResponse: Codable {
//    public var restaurants: [RatedRestaurantsTable]
//
//    public init(restaurants: [RatedRestaurantsTable]) {
//        self.restaurants = restaurants
//    }
//}
//
//public struct RejoinPartyResponse: Codable {
//    public let partyID: UUID
//
//    public init(partyID: UUID) {
//        self.partyID = partyID
//    }
//}
