//
//  drinkdModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/28/21.
//

import SwiftUI



struct drinkdModel {
	private enum TransactionTypes: String {
		case pickup
		case delivery
		case restaurant_reservation
	}
	//
	private(set) var localRestaurants: [YelpApiBusinessSearchProperties] = []
	//
	mutating func getLocalRestaurants() -> [YelpApiBusinessSearchProperties] {
		return localRestaurants
	}

	//Checks to see if the transaction array exists. if it does, parse it and fill the needed transaction properties
	mutating func modifyElements(in restaurants: [YelpApiBusinessSearchProperties]) {

		for var element in restaurants {
			let transactionArray = element.transactions ?? [""]

			if (transactionArray.contains(TransactionTypes.pickup.rawValue)) {
				element.pickUpAvailable = true
			}
			if (transactionArray.contains(TransactionTypes.delivery.rawValue)) {
				element.deliveryAvailable = true

			}
			if (transactionArray.contains(TransactionTypes.restaurant_reservation.rawValue)) {
				element.reservationAvailable = true
			}

			localRestaurants.append(element)
		}
	}

	mutating func updateArray()  {

		guard let topCard = localRestaurants.last else { return print("Array Empty") }

//		localRestaurants.remove(at: localRestaurants.count - 1)
		localRestaurants.insert(topCard, at: 0)
		localRestaurants.remove(at: localRestaurants.count - 1)
//		localRestaurants.insert(topCard, at: 1)

		print(localRestaurants.count)
	}

}
