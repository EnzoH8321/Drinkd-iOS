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
    var userID: UUID { get }
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
    public let userID: UUID
    public let username: String
    public let partyCode: Int

    public init(userID: UUID, username: String, partyCode: Int) {
        self.userID = userID
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
    public let userName: String
    public let partyID: UUID
    public let message: String

    public init(userID: UUID, username: String, partyID: UUID, message: String) {
        self.userID = userID
        self.userName = username
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

