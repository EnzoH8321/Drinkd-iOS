//
//  MockNetworkingClass.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 1/11/22.
//

import Firebase
import Foundation
import CoreLocation
@testable import drinkd_iOS

class MockNetworkingClass: NetworkingProtocol {
    
    
    var mockDB = MockDatabaseObject()
    
    func fetchRestaurantsOnStartUp(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {
        
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
            latitude = location.latitude
            longitude = location.longitude
        }
        
        //If defaults are used, then the user location could not be found
        if (longitude == 0.0 || latitude == 0.0) {
            completionHandler(.failure(.noUserLocationFoundError))
            print("ERROR - NO USER LOCATION FOUND ")
            return
        }
        
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
            completionHandler(.failure(.invalidURLError))
            print("ERROR - INVALID URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(viewModel.token)", forHTTPHeaderField: "Authorization")
        
        //URLSession
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error != nil {
                completionHandler(.failure(.generalNetworkError))
                print("ERROR - GENERAL NETWORK ERROR")
                return
            }
            
            //If URLSession returns data, below code block will execute
            if let verifiedData = data {
                
                guard let JSONDecoderValue = try? JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData) else {
                    completionHandler(.failure(.decodingError))
                    print("ERROR - DECODING ERROR")
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
                        viewModel.userDeniedLocationServices = false
                    }
                }
            }
        }.resume()
    }
    
    func fetchUsingCustomLocation(viewModel: PartyViewModel, longitude: Double, latitude: Double, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {
        
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
            completionHandler(.failure(.invalidURLError))
            return
        }
        
        var request = URLRequest(url: url)
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
                        viewModel.model.appendDeliveryOptions(in: JSONArray)
                        viewModel.model.createParty(setURL: url.absoluteString)
                        viewModel.removeSplashScreen = true
                        viewModel.userDeniedLocationServices = false
                        
                    }
                } else {
                    completionHandler(.failure(.generalNetworkError))
                }
            }
            
        }.resume()
        
    }
    
    func fetchRestaurantsAfterJoiningParty(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {
        
        guard let verifiedPartyURL = viewModel.partyURL else {
            print("No URL Found")
            completionHandler(.failure(.noURLFoundError))
            return
        }
        
        guard let verifiedURL = URL(string: verifiedPartyURL) else {
            print("Could not convert string to URL")
            completionHandler(.failure(.invalidURLError))
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
                } else {
                    completionHandler(.failure(.generalNetworkError))
                }
            } else {
                completionHandler(.failure(.generalNetworkError))
            }
            
        }.resume()
    }
    
    func calculateTopThreeRestaurants(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {
        
        
        guard let url = Bundle(for: type(of: self)).url(forResource: "MockTopThreeChoices", withExtension: "json") else {
            completionHandler(.failure(.generalNetworkError))
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if (error != nil ) {
                completionHandler(.failure(.generalNetworkError))
            }
            
            if let verifiedData = data {
            
                DispatchQueue.main.async {
                    
                    do {
                        viewModel.objectWillChange.send()
                        let decoder = JSONDecoder()
                        var testArray: [String: FireBaseTopChoice] = [:]
                        
                        
                        let data = try decoder.decode(FireBaseMaster.self, from: verifiedData)
                        
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
                    } catch {
                        print(error)
                    }
                    
                    
                }
            }
        }.resume()
        
    }
    
    func submitRestaurantScore(viewModel: PartyViewModel) {
        viewModel.objectWillChange.send()
        
        let score: Int = 6
        let currentURLOfTopCard: String = "www.realurl.com"
        //Adds id of card for
        let currentIDOfTopCard: String = "TESTINGID"
        let currentImageURLTopCard: String = "www.imageurl.com"
         
        if (viewModel.isPartyLeader) {
            
            mockDB.party.fakeNumber.topBars.fakeNumber.firstBar = Bar(id: currentIDOfTopCard, image_url: currentImageURLTopCard, score: score, url: currentURLOfTopCard)

            
        } else if (!viewModel.isPartyLeader) {

            mockDB.party.fakeNumber.topBars.fakeNumber.firstBar = Bar(id: currentIDOfTopCard, image_url: currentImageURLTopCard, score: score, url: currentURLOfTopCard)
        }
        
    }
    
    func fetchExistingMessages(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {
        
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
                    //                localReference.removeObserver(withHandle: dbHandle)
                }
            }
        })
        
    }
    
    func removeMessagingObserver(viewModel: PartyViewModel) {
        
    }
    
    func sendMessage(forMessage message: FireBaseMessage, viewModel: PartyViewModel) {
        
    }
    
    func leaveParty(viewModel: PartyViewModel) {
        
    }
    
    func createParty(viewModel: PartyViewModel) {
        var model = viewModel.model
        
        guard let url = Bundle(for: MockNetworkingClass.self).url(forResource: "MockJSON", withExtension: ".json") else {
            return
            
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
        }
        
        model.findDeviceType(device: .phone)
        model.setCurrentToPartyTrue()
        model.setPartyId()
        model.setPartyMaxVotes(toVote: 5)
        model.setPartyName(name: "Enzo")
        model.setPartyTimestamp(toTimeStamp: 1641952840)
        model.setPartyURL(toURL: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(    37.33182)&longitude=\(-122.03118)&limit=10")
        model.setUserLevelToCreator()
    }
    
    
    
    
}
