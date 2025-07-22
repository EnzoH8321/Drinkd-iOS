//
//  Response.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 7/22/25.
//

import Foundation

// Response from the Server back to the Client.
public struct PostRouteResponse: Codable {
    public let currentUserName: String
    public let currentUserID: UUID
    public let currentPartyID: UUID
    public let partyName: String
    public let yelpURL: String

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
