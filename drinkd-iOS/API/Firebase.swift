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

struct FirebaseRestaurantInfo: Equatable, Comparable {
	static func < (lhs: FirebaseRestaurantInfo, rhs: FirebaseRestaurantInfo) -> Bool {
		if (lhs.score == rhs.score) {
			return	lhs.name > rhs.name
		} else {
		return	lhs.score > rhs.score
		}
	}

	var name: String = ""
	var score: Int = 0
	var url: String = ""
	var image_url: String = ""
}
