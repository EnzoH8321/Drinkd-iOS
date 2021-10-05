//
//  drinkdModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/28/21.
//

import SwiftUI
import Firebase


struct drinkdModel {
	private enum TransactionTypes: String {
		case pickup
		case delivery
		case restaurant_reservation
	}

	private(set) var counter: Int = 10
	private(set) var currentlyInParty = false
	private(set) var queryPartyError = false
	private(set) var partyID: String?
	private(set) var partyMaxVotes: String?
	private(set) var partyName: String?
	private(set) var partyTimestamp: Int?
	private(set) var partyURL: String?

	//Database ref
	private(set) var ref = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference()
	//
	private(set) var localRestaurants: [YelpApiBusinessSearchProperties] = []
	//
	private(set) var localRestaurantsDefault:
	[YelpApiBusinessSearchProperties] = []
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
			localRestaurantsDefault.append(element)
		}
	}

	mutating func appendCardsToDecklist()  {
		self.counter -= 1

		if (counter == 0) {
			for element in 0..<localRestaurantsDefault.count {
				localRestaurants.append(localRestaurantsDefault[element])
			}
			counter = 10
		}

	}

	mutating func createParty(setVotes partyVotes: String? = nil, setName partyName: String? = nil, setURL partyURL: String? = nil) {

		self.partyID = String(Int.random(in: 100...20000))
		self.partyMaxVotes = partyVotes
		self.partyName = partyName
		self.partyTimestamp = Int(Date().timeIntervalSince1970 * 1000)
		self.currentlyInParty = true

		if let url = partyURL {
			self.partyURL = url
		}

		guard let partyID = self.partyID else {
			return
		}

		guard let partyMaxVotes = self.partyMaxVotes else {
			return
		}

		guard let partyName = self.partyName else {
			return
		}

		guard let partyTimestamp = self.partyTimestamp else {
			return
		}

		guard let partyURL = self.partyURL else {
			return
		}



		self.ref.child("parties").child(partyID).setValue(["partyTimestamp": partyTimestamp, "partyID": partyID, "partyMaxVotes": partyMaxVotes, "partyName": partyName, "partyURL": partyURL])

	}


	mutating func getParty(getCode partyCode: String? = nil, getVotes votes: String? = nil, getName name: String? = nil, getURL url: String? = nil) {

		if let partyID = partyCode {
			self.partyID = partyID
		}

		if let partyVotes = votes {
			self.partyMaxVotes = partyVotes
		}

		if let partyName = name {
			self.partyName = partyName
		}

		if let siteURL = url {
			self.partyURL = siteURL
		}

	}


	mutating func setPartyDoesNotExist(in value: Bool) {
		if (value) {
			self.queryPartyError = true
		} else {
			self.queryPartyError = false
		}

	}

	mutating func setCurrentToPartyTrue() {
		self.currentlyInParty = true
	}

}
