//
//  FirebaseDB.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/4/21.
//

import SwiftUI

struct FirebaseParties: Codable, Hashable {
	var partyID: String
	var partyMaxVotes: String
	var partyName: String
	var partyTimestamp: Int
	var partyURL: String
}
