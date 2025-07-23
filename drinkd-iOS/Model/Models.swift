//
//  drinkdModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/28/21.
//

import SwiftUI
import Foundation

struct restaurantScoreInfo {
	var name: String
	var	score: Int
	var url: String
	var id: String?
}

struct Party {
    public var username: String
    public var partyID: UUID
    public var partyMaxVotes : Int
    public var partyName: String
    // Yelpy Business API String
    public var yelpURL: String

    public init(username: String, partyID: UUID, partyMaxVotes: Int, partyName: String, yelpURL: String) {
        self.username = username
        self.partyID = partyID
        self.partyMaxVotes = partyMaxVotes
        self.partyName = partyName
        self.yelpURL = yelpURL
    }
}



