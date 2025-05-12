//
//  Requests.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/7/25.
//
import Foundation

// For Client -> Vapor Server & vice versa

public enum RequestTypes {
    case createParty
    case joinParty
    case leaveParty
}

public protocol PartyRequest {

}

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

// Server -> Client
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
