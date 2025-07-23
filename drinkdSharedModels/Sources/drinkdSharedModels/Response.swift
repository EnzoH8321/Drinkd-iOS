//
//  Response.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 7/22/25.
//

import Foundation
// Response from the Server back to the Client.
public struct CreatePartyResponse : Codable {
    public let partyID: UUID

    public init(partyID: UUID) {
        self.partyID = partyID
    }
}

public struct JoinPartyResponse: Codable {
    public let partyID: UUID
    public let partyName: String
    public let yelpURL: String

    public init(partyID: UUID, partyName: String, yelpURL: String) {
        self.partyID = partyID
        self.partyName = partyName
        self.yelpURL = yelpURL
    }

}


public struct RejoinPartyGetResponse: Codable {
    public let username: String
    public let partyID: UUID
    public let partyCode: Int
    public let yelpURL: String
    public let partyName: String

    public init(username: String, partyID: UUID, partyCode: Int, yelpURL: String, partyName: String) {
        self.username = username
        self.partyID = partyID
        self.partyCode = partyCode
        self.yelpURL = yelpURL
        self.partyName = partyName
    }
}

public struct TopRestaurantsGetResponse: Codable {
    public let restaurants: [RatedRestaurantsTable]

    public init(restaurants: [RatedRestaurantsTable]) {
        self.restaurants = restaurants
    }
}
