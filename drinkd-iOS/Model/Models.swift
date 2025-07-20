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
    public var partyID: String
    public var partyMaxVotes : Int
    public var partyName: String
    // Telpy Business API String
    public var yelpURL: String

    public init(partyID: String, partyMaxVotes: Int, partyName: String, url: String) {

        self.partyID = partyID
        self.partyMaxVotes = partyMaxVotes
        self.partyName = partyName
        self.yelpURL = url
    }
}



