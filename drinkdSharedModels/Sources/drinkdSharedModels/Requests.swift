//
//  Requests.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/7/25.
//
import Foundation

// For Client -> Vapor Seriver & vice versa

// Request to create a party
public struct PartyRequest: Codable {
    public let username: String
}


public struct JoinPartyRequest: Codable {
    public let username: String
    public let partyCode: Int
}


