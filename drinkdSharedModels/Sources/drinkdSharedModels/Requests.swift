//
//  Requests.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/7/25.
//


// For Client -> Vapor Seriver & vice versa

// Request to create a party
public struct PartyRequest: Codable {
    public let username: String
}


public struct PartyResponse: Codable {
    public let partyID: String
}
