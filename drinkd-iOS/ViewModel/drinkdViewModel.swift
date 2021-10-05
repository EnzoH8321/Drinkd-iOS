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

	private enum QueryError: Error {
		case businessArrayNotFound
	}

	private enum FireBasePartyProps: String {
		case partyID, partyMaxVotes, partyName, partyTimestamp, partyURL
	}

	@Published var model = drinkdModel()
	var removeSplashScreen = false
	var currentlyInParty:Bool = false
	var queryPartyError = false
	var restaurantList: [YelpApiBusinessSearchProperties] = []
	var partyID: String?
	var partyMaxVotes: String?
	var partyName: String?


	private var ref = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference()

	func fetchLocalRestaurants() {
		//1.Creating the URL we want to read.
		//2.Wrapping that in a URLRequest, which allows us to configure how the URL should be accessed.
		//3.Create and start a networking task from that URL request.
		//4.Handle the result of that networking task.

		//DELETE FOR RELEASE!
		let token = "nX9W-jXWsXSB_gW3t2Y89iwQ-M7SR9-HVBHDAqf1Zy0fo8LTs3Q1VbIVpdeyFu7PehJlkLDULQulnJ3l6q6loIET5JHmcs9i3tJqYEO02f39qKgSCi4DAEVIlgPPX3Yx"

		var longitude: Double = 0.0
		var latitude: Double = 0.0
		let locationFetcher = LocationFetcher()

		//Asks user for their location
		locationFetcher.start()

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
						throw QueryError.businessArrayNotFound
					}

				} catch(QueryError.businessArrayNotFound) {
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

	func getParty(getCode partyCode: String) {
		objectWillChange.send()

		let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(partyCode)")

		//Reads data at a path and listens for changes
		localReference.observe(DataEventType.value, with: { [self] snapshot in

			if(!snapshot.exists()) {
				print("party does not exist")
				self.model.setPartyDoesNotExist(in: true)
				syncVMPropswithModelProps(queryPartyError: self.model.queryPartyError)
			} else {
				//Organizes values into a usable swift object
				guard let value = snapshot.value as? [String: AnyObject] else {
					print("Value cannot be unwrapped to a Swift readable format ")
					self.model.setPartyDoesNotExist(in: true)
					syncVMPropswithModelProps(queryPartyError: self.model.queryPartyError)
					return
				}

				for (key, valueProperty) in value {
					switch key {
					case FireBasePartyProps.partyID.rawValue:
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
				self.model.setPartyDoesNotExist(in: false)
				syncVMPropswithModelProps(getID: self.model.partyID, getVotes: self.model.partyMaxVotes, getPartyName: self.model.partyName, inParty: self.model.currentlyInParty)
//
//				print(self.partyID)
//				print(self.partyMaxVotes)
//				print(self.partyName)
			}

		})

	}

	//Helper function that lets the VM props update with whats in the Model
	func syncVMPropswithModelProps(getID partyID: String? = nil, getVotes votes: String? = nil, getPartyName partyName: String? = nil, queryPartyError partyError: Bool? = nil, inParty currentlyInParty: Bool? = nil) {

		if let partyID = partyID {
			self.partyID = partyID
		}

		if let partyVotes = votes {
			self.partyMaxVotes = partyVotes
		}

		if let partyName = partyName {
			self.partyName = partyName
		}

		if let partyError = partyError {
			self.queryPartyError = partyError
		}

		if let currentlyInParty = currentlyInParty {
			self.currentlyInParty = currentlyInParty
		}

	}
}


struct drinkdViewModel_Previews: PreviewProvider {
	static var previews: some View {
		/*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
	}
}
