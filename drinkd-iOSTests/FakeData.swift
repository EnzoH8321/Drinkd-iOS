//
//  FakeData.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 9/26/25.
//

import Foundation

struct FakePartyLeader {
    static let username = "Leader007"
    static let id: UUID = UUID(uuidString: "F47AC10B-58CC-4372-A567-0E02B2C3D479")!
}

struct FakeGuest {
    static let username = "Guest007"
    static let id: UUID = UUID(uuidString: "C3D4E5F6-1A2B-4C7D-8E9F-0A1B2C3D4E5F")!
}

struct FakeParty {
    static let id: UUID = UUID(uuidString: "C3D3E5F6-1A2B-4C7D-8E9F-0A2B2C3D4E6F")!
    static let restaurantURL = "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=37.774292458506686&longitude=-122.21621476154564&limit=10"
    static let name = "Party007"
    static let code = 345789
}

struct FakeRestaurant {
    static let name = "BestRestaurant007"
    static let rating = 4
    static let imageURL = "https://s3-media0.fl.yelpcdn.com/bphoto/rKctRFj8diqswEkATTDC5g/o.jpg"
    static let partyID = FakeParty.id
    static let id = UUID(uuidString: "B3D3A5F6-1A3B-5C7D-8E9F-0A3B2C3D4E6F")!
}

struct FakeMessage {
    static let text = "Hi how are you?"
    static let id = UUID(uuidString: "A1D3E5F6-2A2B-3C7D-8E9A-0A2B5C3D4E6F")!
}
