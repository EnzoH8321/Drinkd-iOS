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

	var locationFetcher: LocationFetcher
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

	private var ref = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference()

	//Hidden API KEY
	let token = (Bundle.main.infoDictionary?["API_KEY"] as? String)!

	init() {
		locationFetcher = LocationFetcher()
		locationFetcher.start()
	}

	//Fetches a user defined location. Used when user disabled location services.
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

		guard let barList = topBarList["\(currentCardIndex)"] else {
			return print("No restaurant with this key")
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

		if (self.isPartyLeader) {

			localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(self.partyId)")
			localReference.child("topBars").child(self.partyId ).child(name).setValue(["score": score, "url": currentURLOfTopCard, "id": currentIDOfTopCard, "image_url": currentImageURLTopCard ])
			
		} else if (!self.isPartyLeader) {

			localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(self.friendPartyId)")
			localReference.child("topBars").child(self.partyId ).child(name).setValue(["score": score, "url": currentURLOfTopCard, "id": currentIDOfTopCard, "image_url": currentImageURLTopCard ])
		}
	}

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

	func calculateTopThreeRestaurants() {

		let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(self.isPartyLeader ? self.partyId : self.friendPartyId)").child("topBars")

		localReference.observe(DataEventType.value, with: { snapshot in

			if (!snapshot.exists()) {
				print("No one has scored restaurant yet")
			} else {

				DispatchQueue.main.async {
					self.objectWillChange.send()

					do {
						guard let codableData = try? JSONSerialization.data(withJSONObject: snapshot.value) else {
							return print("unable to serialize")
						}
						let decoder = JSONDecoder()
						let data = try decoder.decode(FireBaseMaster.self, from: codableData)
						var testArray: [String: FireBaseTopChoice] = [:]
						for element in data.models {
							for dictionaryElement in element.value.models {

								if (testArray.contains { key, value in key == dictionaryElement.key}) {
									testArray[dictionaryElement.key]?.score += dictionaryElement.value.score
								} else {
									testArray[dictionaryElement.key] = dictionaryElement.value
								}
							}
						}
						let sortedDict = testArray.sorted {

							if ($0.value.score == $1.value.score) {
								return $0.key > $1.key
							} else {
								return $0.value.score > $1.value.score
							}
						}
						let array = Array(sortedDict)

						self.model.appendTopThreeRestaurants(in: array)

					} catch {
						print("error - \(error)")
					}

				}
			}
		})
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

}

struct drinkdViewModel_Previews: PreviewProvider {
	static var previews: some View {
		/*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
	}
}
