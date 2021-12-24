//
//  YelpNetworking.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/2/21.
//

import Foundation
import Firebase


func fetchRestaurantsOnStartUp(viewModel: drinkdViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {

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
		completionHandler(.failure(.noUserLocationFoundError))
		return
	}

	guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
		completionHandler(.failure(.invalidURLError))
		return
	}

	var request = URLRequest(url: url)
	request.httpMethod = "GET"
	request.setValue("Bearer \(viewModel.token)", forHTTPHeaderField: "Authorization")


	//URLSession
	URLSession.shared.dataTask(with: request) { data, response, error in

		if let error = error {
			completionHandler(.failure(.generalNetworkError))
			return
		}

		//If URLSession returns data, below code block will execute
		if let verifiedData = data {

			guard let JSONDecoderValue = try? JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData) else {
				completionHandler(.failure(.decodingError))
				return
			}
			//If you are here, the network should have fetched the data correctly.
			if let JSONArray = JSONDecoderValue.businesses {
				DispatchQueue.main.async {

					viewModel.objectWillChange.send()
					//Checks to see if the function already ran to prevent duplicate calls
					//TODO: We do this because of the 2x networking call made. this prevents doubling up card stack
					if (viewModel.model.localRestaurants.count <= 0) {
						viewModel.model.appendDeliveryOptions(in: JSONArray)
					}
					completionHandler(.success(.connectionSuccess))
					viewModel.model.createParty(setURL: url.absoluteString)
					viewModel.removeSplashScreen = true
					viewModel.userLocationError = false
				}
			}
		}
	}.resume()
}
//
//Fetches a user defined location. Used when user disabled location services.
func fetchUsingCustomLocation(viewModel: drinkdViewModel, longitude: Double, latitude: Double, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {

	guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
		completionHandler(.failure(.invalidURLError))
		return
	}

	var request = URLRequest(url: url)
	request.httpMethod = "GET"
	request.setValue("Bearer \(viewModel.token)", forHTTPHeaderField: "Authorization")

	//URLSession
	URLSession.shared.dataTask(with: request) { data, response, error in

		if let error = error {
			completionHandler(.failure(.generalNetworkError))
			return
		}

		//If URLSession returns data, below code block will execute
		if let verifiedData = data {

			guard let JSONDecoderValue = try? JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData) else {
				completionHandler(.failure(.decodingError))
				return
			}

			if let JSONArray = JSONDecoderValue.businesses {
				DispatchQueue.main.async {
					viewModel.objectWillChange.send()
					completionHandler(.success(.connectionSuccess))
					viewModel.model.appendDeliveryOptions(in: JSONArray)
					viewModel.model.createParty(setURL: url.absoluteString)
					viewModel.removeSplashScreen = true
					viewModel.userLocationError = false
				}
			}
		}

	}.resume()

}

//Fetch restaurant after joining party
func fetchRestaurantsAfterJoiningParty(viewModel: drinkdViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {

	guard let verifiedPartyURL = viewModel.partyURL else {
		print("No URL Found")
		return
	}

	guard let verifiedURL = URL(string: verifiedPartyURL) else {
		print("Could not convert string to URL")
		return
	}

	var request = URLRequest(url: verifiedURL)
	request.httpMethod = "GET"
	request.setValue("Bearer \(viewModel.token)", forHTTPHeaderField: "Authorization")

	//URLSession
	URLSession.shared.dataTask(with: request) { data, response, error in

		if error != nil {
			completionHandler(.failure(.generalNetworkError))
			return
		}

		//If URLSession returns data, below code block will execute
		if let verifiedData = data {

			guard let JSONDecoderValue = try? JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData) else {
				completionHandler(.failure(.decodingError))
				return
			}

			if let JSONArray = JSONDecoderValue.businesses {
				DispatchQueue.main.async {
					viewModel.objectWillChange.send()
					completionHandler(.success(.connectionSuccess))
					viewModel.model.clearAllRestaurants()
					viewModel.model.appendDeliveryOptions(in: JSONArray)
				}
			}
		}

	}.resume()
}

func calculateTopThreeRestaurants(viewModel: drinkdViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {

	let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(viewModel.isPartyLeader ? viewModel.partyId : viewModel.friendPartyId)").child("topBars")

	var dbHandle = DatabaseHandle()

	dbHandle = localReference.observe(DataEventType.value, with: { snapshot in

		if (!snapshot.exists()) {
			completionHandler(.failure(.databaseRefNotFoundError))
			return
		} else {

			DispatchQueue.main.async {

				viewModel.objectWillChange.send()


				let decoder = JSONDecoder()
				var testArray: [String: FireBaseTopChoice] = [:]

				guard let codableData = try? JSONSerialization.data(withJSONObject: snapshot.value as Any) else {
					completionHandler(.failure(.serializationError))
					return
				}

				guard let data = try? decoder.decode(FireBaseMaster.self, from: codableData) else {
					completionHandler(.failure(.decodingError))
					return
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
				completionHandler(.success(.connectionSuccess))
				localReference.removeObserver(withHandle: dbHandle)
			}
		}
	})
}
//Submits user score to server
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

//Fetches chat messages from server
func fetchExistingMessages(viewModel: drinkdViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {

	let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(viewModel.isPartyLeader ? viewModel.partyId : viewModel.friendPartyId)").child("messages")

	var dbHandle = DatabaseHandle()

	dbHandle =  localReference.observe(DataEventType.value, with: { snapshot in

		if (!snapshot.exists()) {
			completionHandler(.failure(.databaseRefNotFoundError))
			return
		} else {

			DispatchQueue.main.async {

				viewModel.objectWillChange.send()

				var messagesArray: [FireBaseMessage] = []

				for messageObj in snapshot.children {

					let messageData = messageObj as! DataSnapshot

					guard let serializedMessageObj = try? JSONSerialization.data(withJSONObject: messageData.value as Any) else {
						completionHandler(.failure(.serializationError))
						return
					}

					guard let decodedMessageObj = try? JSONDecoder().decode(FireBaseMessage.self, from: serializedMessageObj) else {
						completionHandler(.failure(.decodingError))
						return
					}


					let finalMessageObj = FireBaseMessage(id: decodedMessageObj.id, username: decodedMessageObj.username, personalId: decodedMessageObj.personalId, message: decodedMessageObj.message, timestamp: decodedMessageObj.timestamp, timestampString: Date().formatDate(forMilliseconds: decodedMessageObj.timestamp))


					messagesArray.append(finalMessageObj)
				}

				//Sorts Messages by timestamp
				let sortedMessageArray = messagesArray.sorted {
					return $0.timestamp < $1.timestamp
				}
				completionHandler(.success(.connectionSuccess))
				viewModel.model.fetchEntireMessageList(messageList: sortedMessageArray)
				localReference.removeObserver(withHandle: dbHandle)
			}
		}
	})


}

//Sends a new message to the server
func sendMessage(forMessage message: FireBaseMessage, viewModel: drinkdViewModel , completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {

	let localReference =  Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(viewModel.isPartyLeader ? viewModel.partyId : viewModel.friendPartyId)").child("messages") 

	localReference.child("\(message.id)").setValue(["id": message.id, "username": message.username, "personalId": message.personalId, "message": message.message, "timestamp": message.timestamp, "timestampString": Date().formatDate(forMilliseconds: message.timestamp)])

	fetchExistingMessages(viewModel: viewModel) { result in

		switch(result) {
		case .success(_):
			print("Success")
		case .failure(_):
			print("Failure")
		}
	}

	completionHandler(.success(.connectionSuccess))
}

//Leave your current party. If you are the party leader, the party will be disbanded.

