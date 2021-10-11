//
//  FirebaseTopChoices.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/7/21.
//

import SwiftUI

struct ThreeTopChoices {
	var first: FirebaseRestaurantInfo
	var second: FirebaseRestaurantInfo
	var third: FirebaseRestaurantInfo
}



//struct FirebaseTopBars: Codable {
//	var name: [String: FirebaseList]
//}
//
//
//struct FirebaseList: Codable {
//	var name: [String: FirebaseRestaurantInfo]
//}

struct FirebaseRestaurantInfo: Equatable {
	var name: String
	var score: Int
	var url: String
	var image_url: String
}
