//
//  MockNetworkingClass.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 1/11/22.
//

import Foundation
@testable import drinkd_iOS

class MockNetworkingClass: NetworkingProtocol {
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
            latitude = location.latitude
            longitude = location.longitude
        }
        
        //If defaults are used, then the user location could not be found
        if (longitude == 0.0 || latitude == 0.0) {
            completionHandler(.failure(.noUserLocationFoundError))
            print("ERROR - NO USER LOCATION FOUND ")
            return
        }

        guard let url = Bundle(for: MockNetworkingClass.self).url(forResource: "MockJSON", withExtension: ".json") else {
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
    
    func fetchUsingCustomLocation(viewModel: drinkdViewModel, longitude: Double, latitude: Double, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {
        
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
            completionHandler(.failure(.invalidURLError))
            return
        }
        
        print(url)

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
    
    func fetchRestaurantsAfterJoiningParty(viewModel: drinkdViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {
        
    }
    
    func calculateTopThreeRestaurants(viewModel: drinkdViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {
        
    }
    
    func submitRestaurantScore(viewModel: drinkdViewModel) {
        
    }
    
    func fetchExistingMessages(viewModel: drinkdViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {
        
    }
    
    func removeMessagingObserver(viewModel: drinkdViewModel) {
        
    }
    
    func sendMessage(forMessage message: FireBaseMessage, viewModel: drinkdViewModel) {
        
    }
    
    func leaveParty(viewModel: drinkdViewModel) {
        
    }
    
    
}
