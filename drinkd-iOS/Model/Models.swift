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
    public var partyCode: Int
    // Yelpy Business API String
    public var yelpURL: String

    init(username: String, partyID: UUID, partyMaxVotes: Int, partyName: String, partyCode: Int, yelpURL: String) {
        self.username = username
        self.partyID = partyID
        self.partyMaxVotes = partyMaxVotes
        self.partyName = partyName
        self.partyCode = partyCode
        self.yelpURL = yelpURL
    }
}



