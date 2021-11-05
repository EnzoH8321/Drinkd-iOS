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
	var userLocationError = false

	var isPhone: Bool = true
	var removeSplashScreen = true
	var currentlyInParty = false
	var queryPartyError = false
	var restaurantList: [YelpApiBusinessSearchProperties] = []
	var partyCreatorId: String?
	var partyMaxVotes: String?
	var partyName: String?
	var partyURL: String?
	var isPartyLeader: Bool?
	var locationFetcher: LocationFetcher
	var currentCardIndex: Int = 9
	var topBarList: [String: restaurantScoreInfo] = [:]
	var currentScoreOfTopCard: Int = 0
	//Id for someone elses party
	var memberId: String?

	var firstPlace: FirebaseRestaurantInfo = FirebaseRestaurantInfo()
	var secondPlace: FirebaseRestaurantInfo = FirebaseRestaurantInfo()
	var thirdPlace: FirebaseRestaurantInfo = FirebaseRestaurantInfo()

	private var ref = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference()
	//Hidden API KEY
	let token = (Bundle.main.infoDictionary?["API_KEY"] as? String)!

	init() {
		locationFetcher = LocationFetcher()
		locationFetcher.start()
	}

	func fetchUsingCustomLocation(longitude: Double, latitude: Double) {

		guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
			print("Invalid URL")
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")



		//URLSession
		URLSession.shared.dataTask(with: request) { data, response, error in

			//If URLSession returns data, below code block will execute
			if let verifiedData = data {

				do {
					let JSONDecoderValue = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData)
					if let JSONArray = JSONDecoderValue.businesses {
						DispatchQueue.main.async {
							self.objectWillChange.send()
							self.model.appendDeliveryOptions(in: JSONArray)
							self.model.createParty(setURL: url.absoluteString)
							self.restaurantList = self.model.getLocalRestaurants()
							self.removeSplashScreen = true
							self.userLocationError = false
						}
					} else {
						throw ErrorHanding.businessArrayNotFound
					}

				} catch(ErrorHanding.businessArrayNotFound) {
					print("Did not correctly retrieve the Business Array from the Business Search Endpoint")

				} catch {
					print(error)
				}
				return
			}
			//If you are here, URLSession returned error instead of data
			print("\(error?.localizedDescription ?? "Unknown error")")

		}.resume()

	}

	func fetchRestaurantsOnStartUp() {
		//Checks to see if the function already ran to prevent duplicate calls
		if (self.restaurantList.count > 0) {
			return
		}

		self.setDeviceType()


		//1.Creating the URL we want to read.
		//2.Wrapping that in a URLRequest, which allows us to configure how the URL should be accessed.
		//3.Create and start a networking task from that URL request.
		//4.Handle the result of that networking task.
		var longitude: Double = 0.0
		var latitude: Double = 0.0

		//If user location was found, continue
		if let location = locationFetcher.lastKnownLocation {
			latitude = location.latitude
			longitude = location.longitude
		}
		//If defaults are used, then the user location could not be found
		if (longitude == 0.0 || latitude == 0.0) {
			self.userLocationError = true
			print("could not fetch user location")
			return
		}

		guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
			print("Invalid URL")
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")


		//URLSession
		URLSession.shared.dataTask(with: request) { data, response, error in

			//If URLSession returns data, below code block will execute
			if let verifiedData = data {
				do {
					let JSONDecoderValue = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData)
					if let JSONArray = JSONDecoderValue.businesses {

						DispatchQueue.main.async {
							self.objectWillChange.send()
							self.model.appendDeliveryOptions(in: JSONArray)
							self.model.createParty(setURL: url.absoluteString)
							self.restaurantList = self.model.getLocalRestaurants()
							self.removeSplashScreen = true
							self.userLocationError = false
						}
					} else {
						throw ErrorHanding.businessArrayNotFound
					}

				} catch(ErrorHanding.businessArrayNotFound) {
					print("Did not correctly retrieve the Business Array from the Business Search Endpoint")

				} catch {
					print(error)
				}
				return
			}
			//If you are here, URLSession returned error instead of data
			print("\(error?.localizedDescription ?? "Unknown error")")

		}.resume()
	}

	func fetchRestaurantsAfterJoiningParty() {
		objectWillChange.send()

		guard let verifiedPartyURL = self.partyURL else {
			return print("NO URL FOUND")
		}

		guard let verifiedURL = URL(string: verifiedPartyURL) else {
			print("INVALID URL")
			return
		}

		var request = URLRequest(url: verifiedURL)
		request.httpMethod = "GET"
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

		//URLSession
		URLSession.shared.dataTask(with: request) { data, response, error in

			//If URLSession returns data, below code block will execute
			if let verifiedData = data {
				do {
					let JSONDecoderValue = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData)

					if let JSONArray = JSONDecoderValue.businesses {
						DispatchQueue.main.async {
							self.objectWillChange.send()
							self.model.clearAllRestaurants()
							self.model.appendDeliveryOptions(in: JSONArray)
							self.model.createParty(setURL: verifiedURL.absoluteString)
							self.restaurantList = self.model.getLocalRestaurants()
						}
					} else {
						throw ErrorHanding.businessArrayNotFound
					}

				} catch(ErrorHanding.businessArrayNotFound) {
					print("Did not correctly retrieve the Business Array from the Business Search Endpoint")

				} catch {
					print(error)
				}
				return
			}
			//If you are here, URLSession returned error instead of data
			print("\(error?.localizedDescription ?? "Unknown error")")

		}.resume()

	}

	func submitRestaurantScore() {
		objectWillChange.send()

		if topBarList.isEmpty {
			return
		}

		guard let partyID = self.partyCreatorId else {
			return print("ID NOT FOUND")
		}

		guard let barList = topBarList["\(currentCardIndex)"] else {
			return print("No restaurant with this key")
		}

		guard let partyLeader = self.isPartyLeader else {
			return print("NO PARTY LEADER FOUND")
		}

		//Verifies name in case it contains illegal characters
		let unverifiedName = barList.name

		let score: Int = barList.score
		let name: String = unverifiedName.replacingOccurrences(of: "[\\[\\].#$]", with: "", options: .regularExpression, range: nil)

		let currentURLOfTopCard: String = model.localRestaurantsDefault[currentCardIndex].url ?? "NO URL FOUND"
		//Adds id of card for
		let currentIDOfTopCard: String = model.localRestaurantsDefault[currentCardIndex].id ?? "NO ID FOUND"
		let currentImageURLTopCard: String = model.localRestaurantsDefault[currentCardIndex].image_url ?? "NO IMAGE URL FOUND"
		var localReference: DatabaseReference

		if (partyLeader) {

			localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(partyID)")
			localReference.child("topBars").child(self.partyCreatorId ?? "NO ID").child(name).setValue(["score": score, "url": currentURLOfTopCard, "id": currentIDOfTopCard, "image_url": currentImageURLTopCard ])
			
		} else if (!partyLeader) {

			guard let partyCode = self.memberId else {
				return print("NO Party code available")
			}

			localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(partyID)")
			localReference.child("topBars").child(self.model.memberId ?? "NO ID").child(name).setValue(["score": score, "url": currentURLOfTopCard, "id": currentIDOfTopCard, "image_url": currentImageURLTopCard ])
		}
	}


	func updateRestaurantList() {
		objectWillChange.send()
		model.appendCardsToDecklist()
		self.restaurantList = model.getLocalRestaurants()
	}

	func createNewParty(setVotes partyVotes: String? = nil, setName partyName: String? = nil) {
		objectWillChange.send()
		self.model.createParty(setVotes: partyVotes, setName: partyName)
		self.model.setCurrentToPartyTrue()
		syncVMPropswithModelProps(getID: self.model.partyCreatorId, getVotes: self.model.partyMaxVotes, getPartyName: self.model.partyName, inParty: self.model.currentlyInParty, partyLeader: self.model.isPartyLeader)
	}

	func calculateTopThreeRestaurants() {

		if let verifiedPartyID = self.partyCreatorId {
			let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(verifiedPartyID)").child("topBars")

			localReference.observe(DataEventType.value, with: { snapshot in

				if (!snapshot.exists()) {
					print("No one has scored restaurant yet")
				} else {

					DispatchQueue.main.async {
						//						self.objectWillChange.send()
						let restaurantArray: [[String: Any]] = []
						var verifiedRestaurantArray: [FirebaseRestaurantInfo] = []
						var nonDuplicateArray: [FirebaseRestaurantInfo] = []
						var finalizedArray: [FirebaseRestaurantInfo] = []

//						guard let value = snapshot.value as? [String: Any] else {
//							print("could not convert to swift type")
//							return
//						}



						guard let codableData = try? JSONSerialization.data(withJSONObject: snapshot.value) else {
							return print("unable to serialize")
						}

						print("codable data - \(codableData)")

						do {
							let decoder = JSONDecoder()
							let data = try decoder.decode(FireBaseMaster.self, from: codableData)
							print(data.models)
						} catch {
							print("error - \(error)")
						}


//						//Appends to a temporary array
//						for (_, val) in value {
//							for (key2, val2) in val {
//								restaurantArray.append([key2: val2])
//							}
//						}

						//Iterate through non verified array (array not decoded properly)
						for element in 0..<restaurantArray.count {
							let currentDict = restaurantArray[element]

							var currentName: String = ""
							var currentScore: Int = 0
							let currentURL: String = ""
							let imageURL: String = ""

							var restaurant = FirebaseRestaurantInfo(name: currentName, score: currentScore, url: currentURL, image_url: imageURL)

							for (key, value) in currentDict {
								currentName = key

								restaurant.name = key

								let valueToDict = value as! [String: Any]

								for (keyForDetail, valueForDetail) in valueToDict {

									if valueForDetail is String {

										switch (keyForDetail) {
										case "url":
											restaurant.url = valueForDetail as! String
										case "image_url":
											restaurant.image_url = valueForDetail as! String
										default:
											break
										}

									} else {
										_ = valueForDetail as! Int

										switch (keyForDetail) {
										case "score":
											currentScore = valueForDetail as! Int
											restaurant.score = valueForDetail as! Int
										default:
											break
										}
									}
								}
							}

							verifiedRestaurantArray.append(restaurant)
						}

						for element in verifiedRestaurantArray {
							let currentRestaurant = element
							//Check to see if element in verifiedrestaurantarray is a duplicate
							let filtered = verifiedRestaurantArray.filter { value in
								value.name == currentRestaurant.name
							}
							//iterate through duplicate array
							if (filtered.count > 1) {

								var name: String = ""
								var score: Int = 0
								var url: String = ""
								var imageURL: String = ""

								for element in filtered {
									name = element.name
									score += element.score
									url = element.url
									imageURL = element.image_url

								}

								for restaurant in 0..<filtered.count {
									let currentRestaurant = filtered[restaurant]
									guard let lastIndex = verifiedRestaurantArray.lastIndex(of: currentRestaurant) else {
										print("last index not found")
										return
									}
									verifiedRestaurantArray.remove(at: lastIndex)

								}

								let restaurant = FirebaseRestaurantInfo(name: name, score: score, url: url, image_url: imageURL)
								nonDuplicateArray.append(restaurant)
							}
						}

						//append nonDuplicate to final array
						for element in nonDuplicateArray {
							finalizedArray.append(element)
						}

						for element in verifiedRestaurantArray {
							finalizedArray.append(element)
						}

						//sort so that highest scores are at the start
						let sortedArray = finalizedArray.sorted {
							$0.score > $1.score
						}

						//
						self.model.appendTopThreeRestaurants(in: sortedArray)

						self.syncVMPropswithModelProps(firstPlace: self.model.topThreeChoicesObject.first, secondPlace: self.model.topThreeChoicesObject.second, thirdPlace: self.model.topThreeChoicesObject.third)
					}
				}
			})
		} else {
			print("Top bars does not exist yet")
		}
	}


	func JoinExistingParty(getCode partyCode: String) {
		objectWillChange.send()

		let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(partyCode)")

		//Reads data at a path and listens for changes
		localReference.observe(DataEventType.value, with: { [self] snapshot in

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
						self.model.joinParty(getID: valueProperty as? String)
					case FireBasePartyProps.partyMaxVotes.rawValue:
						self.model.joinParty(getVotes: valueProperty as? String)
					case FireBasePartyProps.partyName.rawValue:
						self.model.joinParty(getName: valueProperty as? String)
					case FireBasePartyProps.partyURL.rawValue:
						self.model.joinParty(getURL: valueProperty as? String)
					default:
						continue
					}

				}

				self.model.setCurrentToPartyTrue()
				self.queryPartyError = false
				syncVMPropswithModelProps(getID: self.model.partyCreatorId, getVotes: self.model.partyMaxVotes, getPartyName: self.model.partyName, inParty: self.model.currentlyInParty, getURL: self.model.partyURL, partyLeader: self.model.isPartyLeader, partyCode: self.model.memberId)

			}

		})
	}

	//Helper function that lets the VM props update with whats in the Model
	func syncVMPropswithModelProps(getID partyID: String? = nil, getVotes votes: String? = nil, getPartyName partyName: String? = nil, inParty currentlyInParty: Bool? = nil, getURL partyURL: String? = nil, getCardIndex cardIndex: Int? = nil, topBar topBarList: [String: restaurantScoreInfo]? = nil, topCardScore currentTopCard: Int? = nil, firstPlace: FirebaseRestaurantInfo? = nil, secondPlace: FirebaseRestaurantInfo? = nil, thirdPlace: FirebaseRestaurantInfo? = nil, partyLeader: Bool? = nil, partyCode: String? = nil, deviceType: Bool? = nil ) {

		if let partyID = partyID {
			self.partyCreatorId = partyID
		}

		if let partyVotes = votes {
			self.partyMaxVotes = partyVotes
		}

		if let partyName = partyName {
			self.partyName = partyName
		}


		if let currentlyInParty = currentlyInParty {
			self.currentlyInParty = currentlyInParty
		}

		if let partyURL = partyURL {
			self.partyURL = partyURL
		}

		if let cardIndex = cardIndex {
			self.currentCardIndex = cardIndex
		}

		if let topBarList = topBarList {
			self.topBarList = topBarList
		}

		if let currentTopCardScore = currentTopCard {
			self.currentScoreOfTopCard = currentTopCardScore
		}

		if let firstPlaceRestaurant = firstPlace {
			self.firstPlace = firstPlaceRestaurant
		}

		if let secondPlaceRestaurant = secondPlace {
			self.secondPlace = secondPlaceRestaurant
		}

		if let thirdPlaceRestaurant = thirdPlace {
			self.thirdPlace = thirdPlaceRestaurant
		}

		if let partyLeader = partyLeader {
			self.isPartyLeader = partyLeader
		}

		if let partyCode = partyCode {
			self.memberId = partyCode
		}

		if let deviceType = deviceType {
			self.isPhone = deviceType
		}

	}



	func whenCardIsDraggedFromView() {
		self.model.removeCardFromDeck()
		syncVMPropswithModelProps(getCardIndex: self.model.currentCardIndex)
	}

	func whenStarIsTapped(getPoints: Int) {
		self.model.addScoreToCard(points: getPoints)
		syncVMPropswithModelProps(topBar: self.model.topBarList, topCardScore: self.model.currentScoreOfTopCard)
	}

	func setCurrentTopCardScoreToZero() {
		self.model.setCurrentTopCardScoreToZero()
		syncVMPropswithModelProps(topCardScore: self.model.currentScoreOfTopCard)
	}

	func emptyTopBarList() {
		self.model.emptyTheTopBarList()
		syncVMPropswithModelProps(topBar: self.model.topBarList)
	}

	func leaveParty() {
		objectWillChange.send()

		guard let partyLeader = self.isPartyLeader else {
			return print("You are not in a party")
		}

		guard let verifiedPartyID = self.partyCreatorId else {
			return print("No Party ID Found")
		}
		//Does not delete the test app
		if (verifiedPartyID == "11727") {
			print("You cannot remove the ")
			self.model.leaveParty()
			syncVMPropswithModelProps(inParty: self.model.currentlyInParty,  partyLeader: self.model.isPartyLeader)
			return
		}

		if (partyLeader) {
			let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(verifiedPartyID)")
			localReference.removeValue()

		} else if (!partyLeader) {

			guard let verifiedMemberId = self.memberId else {
				return print("No Party Code Found")
			}

			let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(verifiedPartyID)").child("topBars").child("\(verifiedMemberId)")
			localReference.removeValue()
		}

		self.model.leaveParty()
		syncVMPropswithModelProps(getID: self.model.partyCreatorId,inParty: self.model.currentlyInParty, firstPlace: self.model.topThreeChoicesObject.first, secondPlace: self.model.topThreeChoicesObject.second, thirdPlace: self.model.topThreeChoicesObject.third, partyLeader: self.model.isPartyLeader )
	}

	func removeImageUrl() {
		self.firstPlace.image_url = ""
		self.secondPlace.image_url = ""
		self.thirdPlace.image_url = ""
	}

	func setDeviceType() {
		let isPhone =  UIDevice.current.userInterfaceIdiom == .phone

		if (isPhone) {
			self.model.findDeviceType(device: .phone)
		} else {
			self.model.findDeviceType(device: .ipad)
		}

		self.syncVMPropswithModelProps(deviceType: self.model.isPhone)

	}

//	func setUserTracking(type: UserPrivacyChoice) {
//		objectWillChange.send()
//		switch type {
//		case .userApprovedTracking:
//			self.userTrackingError = false
//		case .userDeniedTracking:
//			self.userTrackingError = true
//		}
//
//	}
}






struct drinkdViewModel_Previews: PreviewProvider {
	static var previews: some View {
		/*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
	}
}
