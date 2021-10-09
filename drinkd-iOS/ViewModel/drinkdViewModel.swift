//
//  drinkdViewModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import Foundation
import SwiftUI
import Firebase


class drinkdViewModel: ObservableObject {

	private enum ErrorHanding: Error {
		case businessArrayNotFound
	}

	private enum FireBasePartyProps: String {
		case partyId, partyMaxVotes, partyName, partyTimestamp, partyURL
	}

	@Published var model = drinkdModel()
	var removeSplashScreen = true
	var currentlyInParty = false
	var queryPartyError = false
	var restaurantList: [YelpApiBusinessSearchProperties] = []
	var partyID: String?
	var partyMaxVotes: String?
	var partyName: String?
	var partyURL: String?
	var locationFetcher: LocationFetcher
	var currentCardIndex: Int = 9
	var topBarList: [String: restaurantScoreInfo] = [:]
	var currentScoreOfTopCard: Int = 0

	private var ref = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference()

	//DELETE FOR RELEASE!
	let token = "nX9W-jXWsXSB_gW3t2Y89iwQ-M7SR9-HVBHDAqf1Zy0fo8LTs3Q1VbIVpdeyFu7PehJlkLDULQulnJ3l6q6loIET5JHmcs9i3tJqYEO02f39qKgSCi4DAEVIlgPPX3Yx"

	init() {
		locationFetcher = LocationFetcher()
		locationFetcher.start()
	}

	func fetchLocalRestaurants() {
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
							self.model.modifyElements(in: JSONArray)
							self.model.createParty(setURL: url.absoluteString)
							self.restaurantList = self.model.getLocalRestaurants()
							self.removeSplashScreen = true
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

		//		} else {
		//			print("location unknown")
		//		}


	}

	func fetchNewRestaurants() {

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
							self.model.modifyElements(in: JSONArray)
							self.model.createParty(setURL: verifiedURL.absoluteString)
							self.restaurantList = self.model.getLocalRestaurants()
							//							self.removeSplashScreen = true
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

	func sendFirebaseRestaurantScores() {
		objectWillChange.send()

		if topBarList.isEmpty {
			return
		}

		guard let partyID = self.partyID else {
			return print("ID NOT FOUND")
		}

		guard let barList = topBarList["\(currentCardIndex)"] else {
			return print("No restaurant with this key")
		}


		let score: Int = barList.score
		let name: String = barList.name
		let currentURLOfTopCard: String = model.localRestaurantsDefault[currentCardIndex].url ?? "NO URL FOUND"

		let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(partyID)")


		localReference.child("topBars").child(self.partyID ?? "NOID").child(name).setValue(["score": score, "url": currentURLOfTopCard])

	}


	func updateRestaurantList() {
		objectWillChange.send()
		model.appendCardsToDecklist()
		self.restaurantList = model.getLocalRestaurants()
	}

	func setPartyProperties(setVotes partyVotes: String? = nil, setName partyName: String? = nil) {
		objectWillChange.send()
		model.createParty(setVotes: partyVotes, setName: partyName)
		syncVMPropswithModelProps(getID: self.model.partyID, getVotes: self.model.partyMaxVotes, getPartyName: self.model.partyName, inParty: self.model.currentlyInParty)
	}

	func getTopThreeChoices() {
		objectWillChange.send()

		if let verifiedPartyID = self.partyID {
			let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(verifiedPartyID)").child("topBars")

			localReference.observe(DataEventType.value, with: { snapshot in

				if (!snapshot.exists()) {
					print("party does not exist")
				} else {

					var currentRestaurantName = ""
					var restaurantArray: [[String: Any]] = []
					var verifiedRestaurantArray: [FirebaseRestaurantInfo] = []
					var nonDuplicateArray: [FirebaseRestaurantInfo] = []

					guard let value = snapshot.value as? [String: [String: [String: Any]]] else {
						print("could not convert to swift type")
						return
					}
					//Appends to a temporary array
					for (key, val) in value {
						for (key2, val2) in val {
							restaurantArray.append([key2: val2])
						}
					}

					//
					for element in 0..<restaurantArray.count {
						let currentDict = restaurantArray[element]

						var currentName: String = ""
						var currentScore: Int = 0
						var currentURL: String = ""

						var restaurant = FirebaseRestaurantInfo(name: currentName, score: currentScore, url: currentURL)

						for (key, value) in currentDict {
							currentName = key

							restaurant.name = key

							let valueToDict = value as! [String: Any]

							for (keyForDetail, valueForDetail) in valueToDict {

								if let detailAsString = valueForDetail as? String {

									switch (keyForDetail) {
									case "url":
										restaurant.url = valueForDetail as! String
									default:
										print("default")
									}

								} else {
									let detailAsNumber = valueForDetail as! Int

									switch (keyForDetail) {
									case "score":
										currentScore = valueForDetail as! Int
										restaurant.score = valueForDetail as! Int
									default:
										print("default")
									}
								}
							}
						}

							verifiedRestaurantArray.append(restaurant)
					}



					for element in 0..<verifiedRestaurantArray.count {
						let currentRestaurant = verifiedRestaurantArray[element]

						let filtered = verifiedRestaurantArray.filter { value in
							value.name == currentRestaurant.name
						}

						if (currentRestaurant.name == skipName) {
							print("skipped")
							continue
						}


						if (filtered.count > 1) {

							var name: String = ""
							var score: Int = 0
							var url: String = ""


							for element in filtered {
								name = element.name
								score += element.score
								url = element.url
								skipName = element.name
							}


						
							let restaurant = FirebaseRestaurantInfo(name: name, score: score, url: url)
							nonDuplicateArray.append(restaurant)
						}

//						print(currentRestaurant.name)
//						print(skipName)

					}

					print(nonDuplicateArray)
				}
			})
		}
	}


	func getParty(getCode partyCode: String) {
		objectWillChange.send()

		let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(partyCode)")

		//Reads data at a path and listens for changes
		localReference.observe(DataEventType.value, with: { [self] snapshot in

			if(!snapshot.exists()) {
				print("party does not exist")
				self.queryPartyError = true
			} else {
				//Organizes values into a usable swift object
				guard let value = snapshot.value as? [String: AnyObject] else {
					print("Value cannot be unwrapped to a Swift readable format ")
					return
				}

				for (key, valueProperty) in value {
					switch key {
					case FireBasePartyProps.partyId.rawValue:
						self.model.getParty(getCode: valueProperty as? String)
					case FireBasePartyProps.partyMaxVotes.rawValue:
						self.model.getParty(getVotes: valueProperty as? String)
					case FireBasePartyProps.partyName.rawValue:
						self.model.getParty(getName: valueProperty as? String)
					case FireBasePartyProps.partyURL.rawValue:
						self.model.getParty(getURL: valueProperty as? String)
					default:
						continue
					}

				}

				self.model.setCurrentToPartyTrue()
				self.queryPartyError = false
				syncVMPropswithModelProps(getID: self.model.partyID, getVotes: self.model.partyMaxVotes, getPartyName: self.model.partyName, inParty: self.model.currentlyInParty, getURL: self.model.partyURL)

			}

		})

	}

	//Helper function that lets the VM props update with whats in the Model
	func syncVMPropswithModelProps(getID partyID: String? = nil, getVotes votes: String? = nil, getPartyName partyName: String? = nil, inParty currentlyInParty: Bool? = nil, getURL partyURL: String? = nil, getCardIndex cardIndex: Int? = nil, topBar topBarList: [String: restaurantScoreInfo]? = nil, topCardScore currentTopCard: Int? = nil ) {

		if let partyID = partyID {
			self.partyID = partyID
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

	}



	func removeCardfromDeck() {
		self.model.removeCardFromDeck()
		syncVMPropswithModelProps(getCardIndex: self.model.currentCardIndex)
	}

	func addPoints(getPoints: Int) {
		self.model.addScoreToCard(points: getPoints)
		syncVMPropswithModelProps(topBar: self.model.topBarList, topCardScore: self.model.currentScoreOfTopCard)
	}

	func setCurrentTopCardScoreToZero() {
		self.model.setCurrentTopCardScoreToZero()
		syncVMPropswithModelProps(topCardScore: self.model.currentScoreOfTopCard)
	}

	func setListEmpty() {
		self.model.setListEmpty()
		syncVMPropswithModelProps(topBar: self.model.topBarList)
	}

}


struct drinkdViewModel_Previews: PreviewProvider {
	static var previews: some View {
		/*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
	}
}
