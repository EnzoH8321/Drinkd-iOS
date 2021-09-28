//
//  drinkdModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/28/21.
//

import SwiftUI



struct drinkdModel {

	private(set) var localRestaurants: [YelpApiBusinessSearchProperties] = []


	mutating func setLocalRestaurants(in restaurants: [YelpApiBusinessSearchProperties]) {
		localRestaurants = restaurants
		print(localRestaurants)
	}
}

