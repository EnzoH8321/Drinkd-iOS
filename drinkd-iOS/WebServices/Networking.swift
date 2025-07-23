//
//  YelpNetworking.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/2/21.
//

import Foundation
import drinkdSharedModels
import Vapor
import SwiftUI

protocol NetworkingProtocol {
    func fetchRestaurantsOnStartUp(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, ClientNetworkErrors>) -> Void)
    func fetchUsingCustomLocation(viewModel: PartyViewModel, longitude: Double, latitude: Double, completionHandler: @escaping (Result<NetworkSuccess, ClientNetworkErrors>) -> Void)
    func fetchRestaurantsAfterJoiningParty(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, ClientNetworkErrors>) -> Void)
    func calculateTopThreeRestaurants(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, ClientNetworkErrors>) -> Void)
    func submitRestaurantScore(viewModel: PartyViewModel)
    func fetchExistingMessages(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, ClientNetworkErrors>) -> Void)
    func removeMessagingObserver(viewModel: PartyViewModel)    
}
@Observable
final class Networking {

    static let shared = Networking()
    private init() { }

    private(set) var userDeniedLocationServices = false
    var locationFetcher = LocationFetcher()

    func updateUserDeniedLocationServices() {
        self.userDeniedLocationServices = locationFetcher.errorWithLocationAuth
    }

    func updateRestaurants(viewModel: PartyViewModel) async throws {

        //If user location was found, continue
        //If defaults are used, then the user location could not be found
        guard let latitude = locationFetcher.lastKnownLocation?.latitude,
              let longitude = locationFetcher.lastKnownLocation?.longitude,
              latitude != 0.0 || longitude != 0.0 else
        {
            Log.networking.fault("ERROR - NO USER LOCATION FOUND ")
            throw ClientNetworkErrors.noUserLocationFoundError
        }

        let businessSearch = try await getRestaurants(latitude: latitude, longitude: longitude)

        guard let businesses = businessSearch.businesses else { throw SharedErrors.yelp(error: .missingProperty("Missing businesses property"))}

        await MainActor.run {

            //Checks to see if the function already ran to prevent duplicate calls
            //TODO: We do this because of the 2x networking call made. this prevents doubling up card stack
            if (viewModel.localRestaurants.count <= 0) {
                viewModel.updateLocalRestaurants(in: businesses)
            }

            viewModel.removeSplashScreen = true
            self.userDeniedLocationServices = false
        }
    }

    func updateRestaurants(viewModel: PartyViewModel, longitude: Double, latitude: Double) async throws {

        //If user location was found, continue
        //If defaults are used, then the user location could not be found
        guard latitude != 0.0 || longitude != 0.0 else
        {
            Log.networking.fault("ERROR - NO USER LOCATION FOUND ")
            throw ClientNetworkErrors.noUserLocationFoundError
        }

        let businessSearch = try await getRestaurants(latitude: latitude, longitude: longitude)

        guard let businesses = businessSearch.businesses else { throw SharedErrors.yelp(error: .missingProperty("Missing businesses property"))}

        await MainActor.run {

            //Checks to see if the function already ran to prevent duplicate calls
            //TODO: We do this because of the 2x networking call made. this prevents doubling up card stack
            if (viewModel.localRestaurants.count <= 0) {
                viewModel.updateLocalRestaurants(in: businesses)
            }

            viewModel.removeSplashScreen = true
            self.userDeniedLocationServices = false
        }
    }

    private func getRestaurants(latitude: Double, longitude: Double) async throws -> YelpApiBusinessSearch {
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
            Log.networking.fault("ERROR - INVALID URL")
            throw ClientNetworkErrors.invalidURLError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode

            // Check for errors
            if !(200...299).contains(statusCode) {
                throw SharedErrors.yelp(error: .invalidHTTPStatus("Invalid HTTP Status Code - \(statusCode)"))
            }
        }


        let businessSearch = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: data)

        return businessSearch
    }

    private func getRestaurants(yelpURL: String) async throws -> YelpApiBusinessSearch {
        guard let url = URL(string: yelpURL) else {
            Log.networking.fault("ERROR - INVALID URL")
            throw ClientNetworkErrors.invalidURLError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode

            // Check for errors
            if !(200...299).contains(statusCode) {
                throw SharedErrors.yelp(error: .invalidHTTPStatus("Invalid HTTP Status Code - \(statusCode)"))
            }
        }


        let businessSearch = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: data)

        return businessSearch
    }


}

//MARK: Client -> Vapor Server
extension Networking {

    func createParty(viewModel: PartyViewModel, username: String, partyName: String ,restaurantsURL: String) async throws {
        guard let userID = UserDefaultsWrapper.getUserID() else { throw SharedErrors.general(error: .userDefaultsError("Unable to find user ID"))}
        let urlRequest = try createPartyReq(userID: userID, userName: username ,restaurantsUrl: restaurantsURL, partyName: partyName)
        let data =  try await postCall(urlReq: urlRequest)
        let response = try JSONDecoder().decode(CreatePartyResponse.self, from: data)
        UserDefaultsWrapper.setPartyID(id: response.partyID)

        let party = Party(username: username ,partyID: response.partyID.uuidString, partyMaxVotes: 0, partyName: partyName, yelpURL: restaurantsURL)

        await MainActor.run {
            viewModel.currentParty = party
        }

    }

    func leaveParty(partyVM: PartyViewModel, partyID: UUID) async throws  {

        guard let userID = UserDefaultsWrapper.getUserID() else { throw SharedErrors.general(error: .userDefaultsError("Unable to find user ID"))}
        let urlReq = try leavePartyReq(userID: userID)
        await cancelWSConnection(partyVM: partyVM, partyID: partyID)
        let _ = try await postCall(urlReq: urlReq)
    }

    func sendMessage(message: String, partyID: UUID) async throws {

        guard let userID = UserDefaultsWrapper.getUserID() else { throw SharedErrors.general(error: .userDefaultsError("Unable to find user ID"))}
        let urlReq = try sendMsgReq(userID: userID, message: message, partyID: partyID)
        let _ = try await postCall(urlReq: urlReq)
    }

    func addRating(partyID: UUID, userID: UUID, username: String, restaurantName: String, rating: Int, imageURL: String) async throws  {

        let urlReq = try updateRatingReq(partyID: partyID, userName: username, userID: userID, restaurantName: restaurantName, rating: rating, imageuRL: imageURL)
        let _ = try await postCall(urlReq: urlReq)
    }

    func getTopRestaurants(partyID: UUID) async throws -> [RatedRestaurantsTable] {
        let urlString = HTTP.get(.topRestaurants).fullURLString
        let urlReq = try topRestaurantsReq(partyID: partyID, url: urlString)
        let data = try await getCall(urlReq: urlReq)
        let response = try JSONDecoder().decode(TopRestaurantsGetResponse.self, from: data)

        if response.restaurants.count == 0 {
            throw SharedErrors.general(error: .generalError("Restaurants Property is empty."))
        }

        var restaurants = response.restaurants

        for i in restaurants.indices {
            let url = URL(string: restaurants[i].image_url)!
            let (data, _) = try await URLSession.shared.data(from: url)
            restaurants[i].imageData = data
        }

        return restaurants
    }

    func joinParty(viewModel: PartyViewModel, partyCode: Int, userName: String) async throws {
        // Check VM if the user is already in a party
        if viewModel.currentlyInParty == true { return }

        guard let userID = UserDefaultsWrapper.getUserID() else { throw SharedErrors.general(error: .userDefaultsError("Unable to find user ID"))}

        let urlReq = try joinPartyReq(userID: userID, partyCode: partyCode, userName: userName)

        let data = try await postCall(urlReq: urlReq)
        let response = try JSONDecoder().decode(JoinPartyResponse.self, from: data)

        let party = Party(username: userName ,partyID: response.partyID.uuidString, partyMaxVotes: 0, partyName: response.partyName, yelpURL: response.yelpURL)

        let businessSearch = try await getRestaurants(yelpURL: party.yelpURL)

        guard let businesses = businessSearch.businesses else { throw SharedErrors.yelp(error: .missingProperty("Missing businesses property"))}

        await MainActor.run {

            //Checks to see if the function already ran to prevent duplicate calls
            //TODO: We do this because of the 2x networking call made. this prevents doubling up card stack
            if (viewModel.localRestaurants.count <= 0) {
                viewModel.updateLocalRestaurants(in: businesses)
            }
            viewModel.currentParty = party
            viewModel.removeSplashScreen = true
            self.userDeniedLocationServices = false
        }

    }

    func rejoinParty(viewModel: PartyViewModel) async throws  {
        let urlString = HTTP.get(.rejoinParty).fullURLString
        guard let userID = UserDefaultsWrapper.getUserID() else { throw SharedErrors.general(error: .userDefaultsError("Unable to find user ID"))}
        let urlReq = try rejoinPartyReq(userID: userID.uuidString, url: urlString)
        let data = try await getCall(urlReq: urlReq)
        let response = try JSONDecoder().decode(RejoinPartyGetResponse.self, from: data)

        let party = Party(username: response.username, partyID: response.partyID.uuidString, partyMaxVotes: 0, partyName: response.partyName, yelpURL: response.yelpURL)

        let businessSearch = try await getRestaurants(yelpURL: party.yelpURL)

        guard let businesses = businessSearch.businesses else { throw SharedErrors.yelp(error: .missingProperty("Missing businesses property"))}

        await MainActor.run {

            //Checks to see if the function already ran to prevent duplicate calls
            //TODO: We do this because of the 2x networking call made. this prevents doubling up card stack
            if (viewModel.localRestaurants.count <= 0) {
                viewModel.updateLocalRestaurants(in: businesses)
            }
            viewModel.currentParty = party
            viewModel.removeSplashScreen = true
            self.userDeniedLocationServices = false
        }

    }



    //MARK: WebSocket code

    func connectToWebsocket(partyVM: PartyViewModel, username: String, userID: UUID, partyID: UUID) async {

        do {

            try await WebSocket.connect(to: "ws://localhost:8080/testWS/\(username)/\(userID.uuidString)/\(partyID.uuidString)") { ws in
                Log.networking.info("WebSocket connected to url - ws://localhost:8080/testWS/\(username)/\(userID.uuidString)/\(partyID.uuidString)")

                partyVM.currentWebsocket = ws

                if let validWS = partyVM.currentWebsocket {
                    // Connected WebSocket.
                    validWS.onBinary { ws, binary in
                        let data = Data(buffer: binary)
                        do {
                            let message = try JSONDecoder().decode(WSMessage.self, from: data)
                            partyVM.chatMessageList.append(message)
                        } catch {
                            Log.networking.fault("Error decoding websocket binary data - \(error)")
                        }
                    }

                    // Check if the websocket connection has closed
                    validWS.onClose.whenComplete { result in
                        switch result {
                        case .success(let success):
                            Log.routes.debug("Successfully closed websocket connection for PARTYID: \(partyID)")
                        case .failure(let failure):
                            Log.routes.fault("Unable to close websocket connection - \(failure)")
                        }
                    }
                } else {
                    Log.routes.fault("PartyVM websocket is nil")
                }

            }

        } catch {
            Log.networking.fault("Error connecting to WebSocket - \(error)")
        }

    }

    func cancelWSConnection(partyVM: PartyViewModel, partyID: UUID) async {
        do {

            guard let vm = partyVM.currentWebsocket else {
                Log.networking.fault("PartyVM websocket is nil")
                return
            }

            try await vm.close()

            partyVM.currentWebsocket = nil

        } catch {
            Log.networking.fault("Error closing WebSocket - \(error)")
        }
    }

}

//MARK: Utilities
extension Networking {

    private func buildPostReq(url: String) throws -> URLRequest {
        guard let url = URL(string: url) else { throw ClientNetworkErrors.invalidURLError }
        var urlRequest = URLRequest(url: url)

        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }

    func createPartyReq(userID: UUID, userName: String, restaurantsUrl: String, partyName: String) throws -> URLRequest {
        do {
            var baseReq = try buildPostReq(url: HTTP.post(.createParty).fullURLString)
            baseReq.httpBody = try JSONEncoder().encode(CreatePartyRequest(username: userName, userID: userID, restaurants_url: restaurantsUrl, partyName: partyName))
            return baseReq
        } catch {
            Log.networking.fault("Error encoding JSON when creating a party - \(error)")
            throw error
        }

    }

    func joinPartyReq(userID: UUID, partyCode: Int, userName: String) throws -> URLRequest {
        do {
            var baseReq = try buildPostReq(url: HTTP.post(.joinParty).fullURLString)
            baseReq.httpBody = try JSONEncoder().encode(JoinPartyRequest(userID: userID, username: userName, partyCode: partyCode))
            return baseReq
        } catch {
            Log.networking.fault("Error encoding JSON when joining a party - \(error)")
            throw error
        }
    }

    func leavePartyReq(userID: UUID) throws -> URLRequest {
        do {
            var baseReq = try buildPostReq(url: HTTP.post(.leaveParty).fullURLString)
            baseReq.httpBody = try JSONEncoder().encode(LeavePartyRequest(userID: userID))
            return baseReq
        } catch {
            Log.networking.fault("Error encoding JSON when leaving a party - \(error)")
            throw error
        }
    }

    func sendMsgReq(userID: UUID, message: String, partyID: UUID) throws -> URLRequest {
        do {
            var baseReq = try buildPostReq(url: HTTP.post(.sendMessage).fullURLString)
            baseReq.httpBody = try JSONEncoder().encode( SendMessageRequest(userID: userID, partyID: partyID, message: message) )
            return baseReq
        } catch {
            Log.networking.fault("Error encoding JSON when sending a message - \(error)")
            throw error
        }
    }

    func updateRatingReq(partyID: UUID,  userName: String ,  userID: UUID,  restaurantName: String, rating: Int,  imageuRL: String) throws -> URLRequest {
        do {
            var baseReq = try buildPostReq(url: HTTP.post(.updateRating).fullURLString)
            baseReq.httpBody = try JSONEncoder().encode( UpdateRatingRequest(partyID: partyID, userID: userID, userName: userName, restaurantName: restaurantName, rating: rating, imageURL: imageuRL))
            return baseReq
        } catch {
            Log.networking.fault("Error encoding JSON when updating a rating - \(error)")
            throw error
        }
    }

    // Get Req
    private func buildGetReq(url: String) throws -> URLRequest {
        guard let url = URL(string: url) else { throw ClientNetworkErrors.invalidURLError }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        return urlRequest
    }

    private func rejoinPartyReq(userID: String, url: String) throws -> URLRequest {
        var urlReq = try buildGetReq(url: url)

        if var components = URLComponents(string: url) {
            components.queryItems = [URLQueryItem(name: "userID", value: userID)]
            urlReq.url = components.url
        } else {
            Log.networking.fault("Unable to create URLComponents")
        }
        return urlReq
    }

    private func topRestaurantsReq(partyID: UUID,  url: String) throws -> URLRequest {
        var urlReq = try buildGetReq(url: url)

        if var components = URLComponents(string: url) {
            components.queryItems = [URLQueryItem(name: "partyID", value: partyID.uuidString)]
            urlReq.url = components.url
        } else {
            Log.networking.fault("Unable to create URLComponents or PartyID")
        }

        return urlReq
    }

    private func getCall(urlReq: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(for: urlReq)
            let httpResponse = response as! HTTPURLResponse

            if httpResponse.statusCode < 200 || httpResponse.statusCode > 200 {
                // Check if Error
                let error = try JSONDecoder().decode(ErrorWrapper.self, from: data)
                throw error.error
            }

            return data

        } catch {
            Log.networking.fault("Error posting data: \(error)")
            throw error
        }
    }


    private func postCall(urlReq: URLRequest) async throws -> Data {

        do {
            let (data, response) = try await URLSession.shared.data(for: urlReq)
            let httpResponse = response as! HTTPURLResponse

            if httpResponse.statusCode < 200 || httpResponse.statusCode > 200 {
                // Check if Error
                let error = try JSONDecoder().decode(ErrorWrapper.self, from: data)
                throw error.error
            }

            return data
        } catch {
            Log.networking.fault("Error posting data: \(error)")
            throw error
        }

    }

}
