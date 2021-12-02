//
//  drinkdModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/28/21.
//

import Firebase
import SwiftUI

struct restaurantScoreInfo {
	var name: String
	var	score: Int
	var url: String
	var id: String?
}

struct drinkdModel {

	private enum TransactionTypes: String {
		case pickup
		case delivery
		case restaurant_reservation
	}

	private enum userLevel: String {
		case creator
		case member
	}

	private(set) var fcmToken: String = ""
	private(set) var isPhone: Bool = true
	private(set) var counter: Int = 10
	private(set) var currentCardIndex: Int = 9
	private(set) var currentlyInParty = false
	private(set) var partyId: String?
	private(set) var partyMaxVotes: Int?
	private(set) var partyName: String?
	private(set) var partyTimestamp: Int?
	private(set) var partyURL: String?
	//Id for someone elses party
	private(set) var friendPartyId: String?
	private(set) var isPartyLeader: Bool?
	private(set) var topBarList: [String: restaurantScoreInfo] = [:]
	private(set) var currentScoreOfTopCard: Int = 0
	private(set) var topThreeRestaurantArray: [[String: FireBaseTopChoice]] = []
	//Database ref
	private(set) var ref = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference()
	//Represents Deck
	private(set) var localRestaurants: [YelpApiBusinessSearchProperties] = []
	//
	private(set) var localRestaurantsDefault: [YelpApiBusinessSearchProperties] = []
	//For top choices view

	private(set) var firstChoice = FirebaseRestaurantInfo()
	private(set) var secondChoice = FirebaseRestaurantInfo()
	private(set) var thirdChoice = FirebaseRestaurantInfo()

	mutating func setToken(token: String) {
		self.fcmToken = token
	}

	//
	mutating func getLocalRestaurants() -> [YelpApiBusinessSearchProperties] {
		return localRestaurants
	}
	//Used when a party is joined
	mutating func clearAllRestaurants() {
		self.localRestaurants.removeAll()
		self.localRestaurantsDefault.removeAll()
	}
	
	//Checks to see if the transaction array exists. if it does, parse it and fill the needed transaction properties
	mutating func appendDeliveryOptions(in restaurants: [YelpApiBusinessSearchProperties]) {
		
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
	
	mutating func createParty(setVotes partyVotes: Int? = nil, setName partyName: String? = nil, setURL partyURL: String? = nil) {
		print("FCM TOKEN -> \(AppDelegate.fcmToken)")
		self.fcmToken = AppDelegate.fcmToken
		self.partyId = String(Int.random(in: 100...20000))
		self.partyMaxVotes = partyVotes
		self.partyName = partyName
		self.partyTimestamp = Int(Date().timeIntervalSince1970 * 1000)
		//TODO: Removed due to it being called on fetchRestaurantonstartup
//		self.currentlyInParty = true
		
		if let url = partyURL {
			self.partyURL = url
		}
		
		guard let partyID = self.partyId else {
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

		self.ref.child("parties").child(partyID).setValue(["partyTimestamp": partyTimestamp, "partyID": partyID, "partyMaxVotes": partyMaxVotes, "partyName": partyName, "partyURL": partyURL, "tokens": [fcmToken: fcmToken]])
		self.setUserLevel(level: .creator)
		
	}

	mutating func joinParty( getVotes votes: Int? = nil,  getURL url: String? = nil) {

		let uniqueID = UUID()

		guard let validFriendPartyId = self.friendPartyId else {
			return
		}

		if let partyVotes = votes {
			self.partyMaxVotes = partyVotes
		}

		if let siteURL = url {
			self.partyURL = siteURL
		}

		self.ref.child("parties").child(validFriendPartyId).child("tokens").updateChildValues([fcmToken: fcmToken])
	}

	mutating func setUserLevelToMember() {
		self.setUserLevel(level: .member)
	}

	mutating func setFriendsPartyId(code: String?) {
		self.friendPartyId = code
	}

	mutating func setPartyName(name: String?) {
		self.partyName = name
	}

	mutating func setCurrentToPartyTrue() {
		self.currentlyInParty = true
	}

	mutating func setPartyId() {
		let partyIdString = String(Int.random(in: 100...20000))
		self.partyId = partyIdString
	}

	mutating func removeCardFromDeck() {
		
		self.currentCardIndex -= 1

		if (self.currentCardIndex < 0) {
			self.currentCardIndex = 9
		}
		
	}

	mutating func addScoreToCard(points: Int) {

		if (points == currentScoreOfTopCard) {
			return
		}

		self.currentScoreOfTopCard = points
		
		topBarList["\(currentCardIndex)"] = restaurantScoreInfo(name: localRestaurantsDefault[currentCardIndex].name ?? "Not Found", score: points, url: self.partyURL ?? "URL NOT FOUND")
	}

	mutating func setCurrentTopCardScoreToZero() {
		self.currentScoreOfTopCard = 0
	}

	mutating func emptyTheTopBarList() {
		self.topBarList.removeAll()
	}

	mutating func appendTopThreeRestaurants(in array: [Dictionary<String, FireBaseTopChoice>.Element]) {
		//Empties Elements
		firstChoice = FirebaseRestaurantInfo()
		secondChoice = FirebaseRestaurantInfo()
		thirdChoice = FirebaseRestaurantInfo()

		for element in 0..<array.count {

			switch (element) {
			case 0:
				let firstElementValues = array[0].value
				let firstElementKey = array[0].key
				firstChoice = FirebaseRestaurantInfo(name: firstElementKey, score: firstElementValues.score, url: firstElementValues.url, image_url: firstElementValues.image_url)
			case 1:
				let secondElementValues = array[1].value
				let secondIndexKey = array[1].key
				secondChoice = FirebaseRestaurantInfo(name: secondIndexKey, score: secondElementValues.score, url: secondElementValues.url, image_url: secondElementValues.image_url)
			case 2:
				let thirdElementValues = array[2].value
				let thirdKey = array[2].key
				thirdChoice = FirebaseRestaurantInfo(name: thirdKey, score: thirdElementValues.score, url: thirdElementValues.url, image_url: thirdElementValues.image_url)
			default:
				break
			}
		}
	}

	private mutating func setUserLevel(level: userLevel) {
		switch (level) {
		case .member:
			self.isPartyLeader = false
		case .creator:
			self.isPartyLeader = true
		}
	}

	mutating func leaveParty() {
		self.currentlyInParty = false
		self.firstChoice = FirebaseRestaurantInfo()
		self.secondChoice = FirebaseRestaurantInfo()
		self.thirdChoice = FirebaseRestaurantInfo()
		self.partyId = ""
	}

	mutating func removeImageUrls(){
		self.firstChoice.image_url = ""
		self.secondChoice.image_url = ""
		self.thirdChoice.image_url = ""
	}

	mutating func findDeviceType(device: DeviceType) {

		switch (device) {
		case .phone:
			self.isPhone = true
		case .ipad:
			self.isPhone = false
		}
	}
}
