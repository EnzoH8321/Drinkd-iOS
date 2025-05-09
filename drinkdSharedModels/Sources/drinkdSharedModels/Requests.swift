//
//  Requests.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/7/25.
//
import Foundation

// For Client -> Vapor Server & vice versa

// Request to create a party
public struct PartyRequest: Codable {
    public let username: String

    public init(username: String) {
        self.username = username
    }
}


public struct JoinPartyRequest: Codable {
    public let username: String
    public let partyCode: Int
}

public struct LeavePartyRequest: Codable {
    public let userID: UUID
    public let partyID: UUID
}


public struct RouteResponse: Codable {
    public let currentUserName: String
    public let currentUserID: UUID
    public let currentPartyID: UUID

    public init(currentUserName: String, currentUserID: UUID, currentPartyID: UUID) {
        self.currentUserName = currentUserName
        self.currentUserID = currentUserID
        self.currentPartyID = currentPartyID
    }
}
