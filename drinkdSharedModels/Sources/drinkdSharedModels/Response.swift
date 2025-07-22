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
