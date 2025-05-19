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
    public var partyLeaderID: String
    public var partyID: String
    public var partyMaxVotes : Int
    public var partyName: String
    public var timestamp: Int
    public var url: String

    public init(partyLeaderID: String, partyID: String, partyMaxVotes: Int, partyName: String, timestamp: Int, url: String) {
        self.partyLeaderID = partyLeaderID
        self.partyID = partyID
        self.partyMaxVotes = partyMaxVotes
        self.partyName = partyName
        self.timestamp = timestamp
        self.url = url
    }
}



