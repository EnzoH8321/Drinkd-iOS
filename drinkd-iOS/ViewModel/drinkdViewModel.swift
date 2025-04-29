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

	var userDeniedLocationServices = false

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
    let token: String = ProcessInfo.processInfo.environment["YELP_APIKEY"]!

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

            if let validSnapshot = snapshot {
                if(!validSnapshot.exists()) {
                    self.queryPartyError = true
                    print("Party does not exist")
                    print(self.queryPartyError)
                    return
                } else {

                    //Organizes values into a usable swift object
                    guard let value = validSnapshot.value as? [String: AnyObject] else {
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

	//Checks if the user accepted location services. 
	func checkIfUserDeniedTracking() {
		objectWillChange.send()
		self.userDeniedLocationServices = locationFetcher.errorWithLocationAuth
	}
}

//struct drinkdViewModel_Previews: PreviewProvider {
//	static var previews: some View {
//		/*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
//	}
//}
