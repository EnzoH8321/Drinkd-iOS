//
//  FirebaseTopChoices.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/7/21.
//

import SwiftUI

struct ThreeTopChoices {
	var first: FirebaseRestaurantInfo?
	var second: FirebaseRestaurantInfo?
	var third: FirebaseRestaurantInfo?
}

struct FirebaseRestaurantInfo: Equatable {
	var name: String = ""
	var score: Int = 0
	var url: String = ""
	var image_url: String = ""
}
