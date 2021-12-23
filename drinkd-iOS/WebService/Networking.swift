//
//  YelpNetworking.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/2/21.
//

import Foundation
import Firebase


func fetchRestaurantsOnStartUp(viewModel: drinkdViewModel) {

	//TODO: Issue where during reload there is a possibility to do a 2x call. Fix issue
	//Checks to see if the function already ran to prevent duplicate calls
	if (viewModel.model.localRestaurants.count > 0) {
		return
	}

	viewModel.setDeviceType()

	//1.Creating the URL we want to read.
	//2.Wrapping that in a URLRequest, which allows us to configure how the URL should be accessed.
	//3.Create and start a networking task from that URL request.
	//4.Handle the result of that networking task.
	var longitude: Double = 0.0
	var latitude: Double = 0.0

	//If user location was found, continue
	if let location = viewModel.locationFetcher.lastKnownLocation {
		print("FETCH WORKED, IT SHOULD POP UP")
		latitude = location.latitude
		longitude = location.longitude
	}
	//If defaults are used, then the user location could not be found
	if (longitude == 0.0 || latitude == 0.0) {
		print("COULD NOT FETCH USER LOCATION")
		return
	}

	guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
		print("Invalid URL")
		return
	}

	var request = URLRequest(url: url)
	request.httpMethod = "GET"
	request.setValue("Bearer \(viewModel.token)", forHTTPHeaderField: "Authorization")


	//URLSession
	URLSession.shared.dataTask(with: request) { data, response, error in

		//If URLSession returns data, below code block will execute
		if let verifiedData = data {
			do {
				let JSONDecoderValue = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData)
				if let JSONArray = JSONDecoderValue.businesses {

					DispatchQueue.main.async {
						
						viewModel.objectWillChange.send()
						//Checks to see if the function already ran to prevent duplicate calls
						//TODO: We do this because of the 2x networking call made. this prevents doubling up card stack
						if (viewModel.model.localRestaurants.count <= 0) {
							viewModel.model.appendDeliveryOptions(in: JSONArray)
						}

						viewModel.model.createParty(setURL: url.absoluteString)
						viewModel.removeSplashScreen = true
						viewModel.userLocationError = false
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
//
//Fetches a user defined location. Used when user disabled location services.
func fetchUsingCustomLocation(viewModel: drinkdViewModel, longitude: Double, latitude: Double) {

	guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
		print("Invalid URL")
		return
	}

	var request = URLRequest(url: url)
	request.httpMethod = "GET"
	request.setValue("Bearer \(viewModel.token)", forHTTPHeaderField: "Authorization")

	//URLSession
	URLSession.shared.dataTask(with: request) { data, response, error in

		//If URLSession returns data, below code block will execute
		if let verifiedData = data {

			do {
				let JSONDecoderValue = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData)
				if let JSONArray = JSONDecoderValue.businesses {
					DispatchQueue.main.async {
						viewModel.objectWillChange.send()
						viewModel.model.appendDeliveryOptions(in: JSONArray)
						viewModel.model.createParty(setURL: url.absoluteString)
						viewModel.removeSplashScreen = true
						viewModel.userLocationError = false
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

//Fetch restaurant after joining party
func fetchRestaurantsAfterJoiningParty(viewModel: drinkdViewModel) {

	guard let verifiedPartyURL = viewModel.partyURL else {
		return print("NO URL FOUND")
	}

	guard let verifiedURL = URL(string: verifiedPartyURL) else {
		print("INVALID URL")
		return
	}

	var request = URLRequest(url: verifiedURL)
	request.httpMethod = "GET"
	request.setValue("Bearer \(viewModel.token)", forHTTPHeaderField: "Authorization")

	//URLSession
	URLSession.shared.dataTask(with: request) { data, response, error in

		//If URLSession returns data, below code block will execute
		if let verifiedData = data {
			do {
				let JSONDecoderValue = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData)

				if let JSONArray = JSONDecoderValue.businesses {
					DispatchQueue.main.async {
						viewModel.objectWillChange.send()
						viewModel.model.clearAllRestaurants()
						viewModel.model.appendDeliveryOptions(in: JSONArray)

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

func calculateTopThreeRestaurants(viewModel: drinkdViewModel) {

	let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(viewModel.isPartyLeader ? viewModel.partyId : viewModel.friendPartyId)").child("topBars")

	localReference.observe(DataEventType.value, with: { snapshot in

		if (!snapshot.exists()) {
			print("No one has scored restaurant yet")
		} else {

			DispatchQueue.main.async {
				viewModel.objectWillChange.send()

				do {
					let decoder = JSONDecoder()
					var testArray: [String: FireBaseTopChoice] = [:]

					guard let codableData = try? JSONSerialization.data(withJSONObject: snapshot.value as Any) else {
						throw NetworkErrors.serializationError
					}

					guard let data = try? decoder.decode(FireBaseMaster.self, from: codableData) else {
						throw NetworkErrors.decodingError
					}

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
					viewModel.model.appendTopThreeRestaurants(in: array)

				} catch NetworkErrors.serializationError {
					print("Data Serialization Error")
				} catch NetworkErrors.decodingError {
					print("JSON Decoding Error")
				} catch {
					print(error)
				}

			}
		}
	})
}

func submitRestaurantScore(viewModel: drinkdViewModel) {
	viewModel.objectWillChange.send()

	guard let barList = viewModel.topBarList["\(viewModel.currentCardIndex)"] else {
		return print("No restaurant with this key")
	}

	//Verifies name in case it contains illegal characters
	let unverifiedName = barList.name
	let score: Int = barList.score
	let name: String = unverifiedName.replacingOccurrences(of: "[\\[\\].#$]", with: "", options: .regularExpression, range: nil)

	let currentURLOfTopCard: String = viewModel.model.localRestaurantsDefault[viewModel.currentCardIndex].url ?? "NO URL FOUND"
	//Adds id of card for
	let currentIDOfTopCard: String = viewModel.model.localRestaurantsDefault[viewModel.currentCardIndex].id ?? "NO ID FOUND"
	let currentImageURLTopCard: String = viewModel.model.localRestaurantsDefault[viewModel.currentCardIndex].image_url ?? "NO IMAGE URL FOUND"
	var localReference: DatabaseReference

	if (viewModel.isPartyLeader) {

		localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(viewModel.partyId)")
		localReference.child("topBars").child(viewModel.partyId ).child(name).setValue(["score": score, "url": currentURLOfTopCard, "id": currentIDOfTopCard, "image_url": currentImageURLTopCard ])

	} else if (!viewModel.isPartyLeader) {

		localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(viewModel.friendPartyId)")
		localReference.child("topBars").child(viewModel.partyId ).child(name).setValue(["score": score, "url": currentURLOfTopCard, "id": currentIDOfTopCard, "image_url": currentImageURLTopCard ])
	}
}
