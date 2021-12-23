//
//  drinkdViewModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import Foundation
import SwiftUI
import Firebase
import AppTrackingTransparency

enum ErrorHanding: Error {
	case businessArrayNotFound
}

class drinkdViewModel: ObservableObject {

	private enum ErrorHanding: Error {
		case businessArrayNotFound
	}

	private enum FireBasePartyProps: String {
		case partyID, partyMaxVotes, partyName, partyTimestamp, partyURL
	}

	@Published var model = drinkdModel()

	var fcmToken: String {
		return model.fcmToken
	}

	//toggle refresh
	var toggleRefresh: Bool {
		return model.toggleRefresh
	}

	var userLocationError = false

	var isPhone: Bool {
		return model.isPhone
	}
	var removeSplashScreen = true
	var currentlyInParty: Bool {
		return model.currentlyInParty
	}
	var isPartyLeader: Bool {
		return model.isPartyLeader ?? false
	}
	var queryPartyError = false
	
	var restaurantList: [YelpApiBusinessSearchProperties] {
		
		return model.localRestaurants
	}
	var partyId: String {
		return model.partyId ?? "No Party ID not Found"
	}
	var partyMaxVotes: Int {
		return model.partyMaxVotes ?? 0
	}
	var partyName: String {
		return model.partyName ?? "No Party Name"
	}
	var partyURL: String? {
		return model.partyURL
	}


	var currentCardIndex: Int {
		return model.currentCardIndex
	}
	var currentScoreOfTopCard: Int{
		return model.currentScoreOfTopCard
	}
	var topBarList: [String: restaurantScoreInfo] {
		return model.topBarList
	}

	//Id for someone elses party
	var friendPartyId: String {
		return model.friendPartyId ?? "Master Party ID not Found"
	}

	var firstPlace: FirebaseRestaurantInfo {
		return model.firstChoice
	}
	var secondPlace: FirebaseRestaurantInfo {
		return model.secondChoice
	}
	var thirdPlace: FirebaseRestaurantInfo {
		return model.thirdChoice
	}

	var ref = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference()

	var locationFetcher = LocationFetcher()
	//Hidden API KEY
	let token = (Bundle.main.infoDictionary?["API_KEY"] as? String)!

	//Chat
	var personalUsername: String {
		return model.personalUserName
	}

	var personalID: Int {
		return model.personalUserID
	}

	var chatMessageList: [FireBaseMessage] {
		return model.chatMessageList
	}

	//

	init() {
		locationFetcher.start()
	}
	//Chat
	func fetchExistingMessages() {

		let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(isPartyLeader ? partyId : friendPartyId)").child("messages")

		localReference.observe(DataEventType.value, with: { snapshot in

			if (!snapshot.exists()) {
				return print("Unable to get messages from Firebase/No current messages")
			} else {

				DispatchQueue.main.async {
					self.objectWillChange.send()

					do {
						var messagesArray: [FireBaseMessage] = []

						for messageObj in snapshot.children {

							let messageData = messageObj as! DataSnapshot

							guard let serializedMessageObj = try? JSONSerialization.data(withJSONObject: messageData.value as Any) else {
								return print("Data Could not be serialized")
							}

							let decodedMessageObj = try JSONDecoder().decode(FireBaseMessage.self, from: serializedMessageObj)


							let finalMessageObj = FireBaseMessage(id: decodedMessageObj.id, username: decodedMessageObj.username, personalId: decodedMessageObj.personalId, message: decodedMessageObj.message, timestamp: decodedMessageObj.timestamp, timestampString: Date().formatDate(forMilliseconds: decodedMessageObj.timestamp))

							messagesArray.append(finalMessageObj)
						}

						//Sorts Messages by timestamp
						let sortedMessageArray = messagesArray.sorted {
							return $0.timestamp < $1.timestamp
						}

						self.model.fetchEntireMessageList(messageList: sortedMessageArray)
						print("Decoded firebase list -> \(self.model.chatMessageList)")
					} catch {
						print(error)
					}

				}
				
			}

		})
	}

	func sendMessage(forMessage message: FireBaseMessage) {
		let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(isPartyLeader ? partyId : friendPartyId)").child("messages")


		localReference.child("\(message.id)").setValue(["id": message.id, "username": message.username, "personalId": message.personalId, "message": message.message, "timestamp": message.timestamp, "timestampString": Date().formatDate(forMilliseconds: message.timestamp)])

		fetchExistingMessages()
	}

	//
	func updateRestaurantList() {
		objectWillChange.send()
		self.model.appendCardsToDecklist()
		
	}


	//called when the create party button in the create party screen in pushed
	func createNewParty(setVotes partyVotes: Int? = nil, setName partyName: String? = nil) {
		objectWillChange.send()
		self.model.createParty(setVotes: partyVotes, setName: partyName)
		self.model.setCurrentToPartyTrue()
	}

	func JoinExistingParty(getCode partyCode: String) {
		objectWillChange.send()

		let topBarsReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(partyCode)")

		//Reads data at a path and listens for changes
		topBarsReference.getData(completion: { error, snapshot in

			if(!snapshot.exists()) {
				print("party does not exist")
				self.queryPartyError = true
				return
			} else {

				//Organizes values into a usable swift object
				guard let value = snapshot.value as? [String: AnyObject] else {
					print("Value cannot be unwrapped to a Swift readable format ")
					return
				}
				for (key, valueProperty) in value {
					switch key {
					case FireBasePartyProps.partyID.rawValue:
						self.model.setFriendsPartyId(code: valueProperty as? String)

					case FireBasePartyProps.partyMaxVotes.rawValue:
						self.model.joinParty(getVotes: valueProperty as? Int)

					case FireBasePartyProps.partyName.rawValue:
						self.model.setPartyName(name: valueProperty as? String)

					case FireBasePartyProps.partyURL.rawValue:
						self.model.joinParty(getURL: valueProperty as? String)

					default:
						continue
					}
				}

				self.model.setUserLevelToMember()
				self.model.setPartyId()
				self.model.setCurrentToPartyTrue()
				self.queryPartyError = false
			}
		})
	}

	func whenCardIsDraggedFromView() {
		objectWillChange.send()
		self.model.removeCardFromDeck()
	}

	func whenStarIsTapped(getPoints: Int) {
		self.model.addScoreToCard(points: getPoints)
	}

	func setCurrentTopCardScoreToZero() {
		self.model.setCurrentTopCardScoreToZero()
	}

	func emptyTopBarList() {
		self.model.emptyTheTopBarList()
	}

	func leaveParty() {
		objectWillChange.send()

		//Does not delete the test app
		if (self.partyId == "11727") {
			self.model.leaveParty()
			return
		}

		if (self.isPartyLeader) {
			let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(self.partyId)")
			localReference.removeValue()

		} else if (!self.isPartyLeader) {
			let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(self.partyId)").child("topBars").child("\(self.friendPartyId)")
			localReference.removeValue()
		}

		self.model.leaveParty()

	}

	func removeImageUrl() {
		objectWillChange.send()
		self.model.removeImageUrls()
	}

	func setDeviceType() {
		let isPhone =  UIDevice.current.userInterfaceIdiom == .phone

		if (isPhone) {
			self.model.findDeviceType(device: .phone)
		} else {
			self.model.findDeviceType(device: .ipad)
		}

	}

	func forModelSetUsernameAndId(username: String, id: Int) {
		self.model.setPersonalUserAndID(forName: username, forID: id)
	}

	//Checks if the user locations could/could not be found
	func setuserLocationError() {
		objectWillChange.send()
		self.userLocationError = locationFetcher.errorWithLocationAuth
		print("userlocationerror -> \(self.userLocationError)")
	}

	

}

struct drinkdViewModel_Previews: PreviewProvider {
	static var previews: some View {
		/*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
	}
}
