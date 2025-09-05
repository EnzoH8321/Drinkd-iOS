//
//  YelpNetworking.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/2/21.
//

import Foundation
import drinkdSharedModels
import SwiftUI

@Observable
final class Networking {

    init(webSocket: WebSocket = WebSocket()) {
        self.webSocket = webSocket
    }

    private var webSocket: WebSocket

    private(set) var userDeniedLocationServices = false
    var locationFetcher = LocationFetcher()

    func updateUserDeniedLocationServices() {
        self.userDeniedLocationServices = locationFetcher.errorWithLocationAuth
    }

    /// Fetches nearby restaurants based on user location and updates the view model with the results.
    func updateRestaurants(viewModel: PartyViewModel) async throws {

        //If user location was found, continue
        //If defaults are used, then the user location could not be found
        guard let latitude = locationFetcher.lastKnownLocation?.latitude,
              let longitude = locationFetcher.lastKnownLocation?.longitude,
              latitude != 0.0 && longitude != 0.0 else
        {
            throw LocationErrors.invalidLastKnownLocation(msg: "Unable to retrieve last known location")
        }

        let businessSearch = try await getRestaurants(latitude: latitude, longitude: longitude)

        guard let businesses = businessSearch.businesses else { throw YelpErrors.missingProperty("Missing businesses property")}

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

    /// Fetches nearby restaurants using provided coordinates and updates the view model with the results.
    /// - Parameter viewModel: The PartyViewModel instance to update with restaurant data
    /// - Parameter longitude: The longitude coordinate for restaurant search
    /// - Parameter latitude: The latitude coordinate for restaurant search
    func updateRestaurants(viewModel: PartyViewModel, longitude: Double, latitude: Double) async throws {

        //If user location was found, continue
        //If defaults are used, then the user location could not be found
        if latitude == 0.0 && longitude == 0.0 { throw LocationErrors.invalidLastKnownLocation(msg: "Invalid Latitude and Longitude") }

        let businessSearch = try await getRestaurants(latitude: latitude, longitude: longitude)

        guard let businesses = businessSearch.businesses else { throw YelpErrors.missingProperty("Missing businesses property")}

        await MainActor.run {

            viewModel.updateLocalRestaurants(in: businesses)

            viewModel.removeSplashScreen = true
            self.userDeniedLocationServices = false
        }
    }

    /// Fetches nearby restaurants from the Yelp API using provided coordinates.
    /// - Parameter latitude: The latitude coordinate for the search
    /// - Parameter longitude: The longitude coordinate for the search
    /// - Returns: YelpApiBusinessSearch containing the API response with business data
     func getRestaurants(latitude: Double, longitude: Double) async throws -> YelpApiBusinessSearch {
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
            Log.error.log("ERROR - INVALID URL")
            throw SharedErrors.general(error: .generalError("Invalid URL"))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.yelpToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode

            // Check for errors
            if !(200...299).contains(statusCode) {
                throw YelpErrors.invalidHTTPStatus("Invalid HTTP Status Code - \(statusCode)")
            }
        }


        let businessSearch = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: data)

        return businessSearch
    }

    /// Fetches restaurant data from the Yelp API using a provided URL string.
    /// - Parameter yelpURL: The complete Yelp API URL string for the request
    /// - Returns: YelpApiBusinessSearch containing the API response with business data
     func getRestaurants(yelpURL: String) async throws -> YelpApiBusinessSearch {
        guard let url = URL(string: yelpURL) else {
            Log.error.log("ERROR - INVALID URL")
            throw SharedErrors.general(error: .generalError("Invalid URL"))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.yelpToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode

            // Check for errors
            if !(200...299).contains(statusCode) {
                throw YelpErrors.invalidHTTPStatus("Invalid HTTP Status Code - \(statusCode)")
            }
        }


        let businessSearch = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: data)

        return businessSearch
    }


}

//MARK: Client -> Vapor Server
extension Networking {

    /// Creates a new party with the specified details and establishes a WebSocket connection.
    /// - Parameter viewModel: The PartyViewModel instance to update with the new party
    /// - Parameter username: The username of the party creator
    /// - Parameter partyName: The name for the new party
    /// - Parameter restaurantsURL: The Yelp API URL for restaurant data
    func createParty(viewModel: PartyViewModel, username: String, partyName: String ,restaurantsURL: String) async throws {
        let userID = try UserDefaultsWrapper.getUserID
        let urlReq = try HTTP.PostReq.createParty(userID: userID, userName: username, restaurantsUrl: restaurantsURL, partyName: partyName).createReq()
        let data = try await executeRequest(urlReq: urlReq)

        let response = try JSONDecoder().decode(CreatePartyResponse.self, from: data)

        let party = Party(username: username ,partyID: response.partyID, partyMaxVotes: 0, partyName: partyName, partyCode: response.partyCode, yelpURL: restaurantsURL)
        await webSocket.rdbSetSubscribeAndListen(partyVM: viewModel, partyID: response.partyID)
        await MainActor.run {
            viewModel.currentParty = party
        }
    }

    /// Removes the current user from the specified party and closes the WebSocket connection.
    /// - Parameter partyVM: The PartyViewModel instance for the party being left
    /// - Parameter partyID: The unique identifier of the party to leave
    func leaveParty(partyVM: PartyViewModel, networking: Networking, partyID: UUID) async throws  {
        let userID = try UserDefaultsWrapper.getUserID
        let urlReq = try HTTP.PostReq.leaveParty(userID: userID).createReq()
        webSocket.cancelWebSocketConnection()
        let _ = try await executeRequest(urlReq: urlReq)

        let location = try networking.locationFetcher.getLocation(partyVM: partyVM).coordinate
        try await networking.updateRestaurants(viewModel: partyVM, longitude: location.longitude, latitude: location.latitude)
    }

    /// Sends a message to the specified party through both WebSocket and HTTP API.
    /// - Parameter username: The username of the message sender
    /// - Parameter message: The text content of the message
    /// - Parameter partyID: The unique identifier of the party to send the message to
    func sendMessage(username: String, message: String, partyID: UUID) async throws {

        let userID = try UserDefaultsWrapper.getUserID
        let urlReq = try HTTP.PostReq.sendMessage(userID: userID, username: username, message: message, partyID: partyID).createReq()
        await webSocket.rdbSendMessage(userName: username, userID: userID, message: message, messageID: UUID(), partyID: partyID)
        let _ = try await executeRequest(urlReq: urlReq)
    }

    /// Submits a user's rating for a restaurant in the specified party.
    /// - Parameter partyID: The unique identifier of the party
    /// - Parameter userID: The unique identifier of the user submitting the rating
    /// - Parameter username: The username of the user submitting the rating
    /// - Parameter restaurantName: The name of the restaurant being rated
    /// - Parameter rating: The numerical rating value for the restaurant
    /// - Parameter imageURL: The URL of the restaurant's image
    func addRating(partyID: UUID, userID: UUID, username: String, restaurantName: String, rating: Int, imageURL: String) async throws  {
        let urlReq = try HTTP.PostReq.updateRating(partyID: partyID, userName: username, userID: userID, restaurantName: restaurantName, rating: rating, imageuRL: imageURL).createReq()
        let _ = try await executeRequest(urlReq: urlReq)
    }

    /// Retrieves the top-rated restaurants for a party with their image data.
    /// - Parameter partyID: The unique identifier of the party
    /// - Returns: Array of RatedRestaurantsTable objects with populated image data
    func getTopRestaurants(partyID: UUID) async throws -> [RatedRestaurantsTable] {
        let urlReq = try HTTP.GetReq.topRestaurants(partyID: partyID).createReq()
        let data = try await executeRequest(urlReq: urlReq)
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
    /// Joins an existing party using a party code and loads restaurant data.
    /// - Parameter viewModel: The PartyViewModel instance to update with party data
    /// - Parameter partyCode: The numeric code for the party to join
    /// - Parameter userName: The username of the user joining the party
    func joinParty(viewModel: PartyViewModel, partyCode: Int, userName: String) async throws {
        // Check VM if the user is already in a party
        if viewModel.currentlyInParty == true { return }

        let userID = try UserDefaultsWrapper.getUserID

        let urlReq = try HTTP.PostReq.joinParty(userID: userID, partyCode: partyCode, userName: userName).createReq()

        let data = try await executeRequest(urlReq: urlReq)
        let response = try JSONDecoder().decode(JoinPartyResponse.self, from: data)

        let party = Party(username: userName ,partyID: response.partyID, partyMaxVotes: 0, partyName: response.partyName, partyCode: response.partyCode, yelpURL: response.yelpURL)

        let businessSearch = try await getRestaurants(yelpURL: party.yelpURL)

        guard let businesses = businessSearch.businesses else { throw YelpErrors.missingProperty("Missing businesses property")}

        await webSocket.rdbSetSubscribeAndListen(partyVM: viewModel, partyID: response.partyID)

        await MainActor.run {
            viewModel.updateLocalRestaurants(in: businesses)
            viewModel.currentParty = party
            viewModel.removeSplashScreen = true
            self.userDeniedLocationServices = false
        }

    }

    /// Rejoins a previously joined party using stored user credentials and restores party state.
    /// - Parameter viewModel: The PartyViewModel instance to update with party data
    func rejoinParty(viewModel: PartyViewModel) async throws  {
        let userID = try UserDefaultsWrapper.getUserID
        let urlReq = try HTTP.GetReq.rejoinParty(userID: userID.uuidString).createReq()
        let data = try await executeRequest(urlReq: urlReq)
        let response = try JSONDecoder().decode(RejoinPartyGetResponse.self, from: data)

        let party = Party(username: response.username, partyID: response.partyID, partyMaxVotes: 0, partyName: response.partyName, partyCode: response.partyCode, yelpURL: response.yelpURL)

        let businessSearch = try await getRestaurants(yelpURL: party.yelpURL)

        guard let businesses = businessSearch.businesses else { throw YelpErrors.missingProperty("Missing businesses property")}

        await MainActor.run {
            viewModel.updateLocalRestaurants(in: businesses)
            viewModel.currentParty = party
            viewModel.removeSplashScreen = true
            self.userDeniedLocationServices = false
        }
        await webSocket.rdbSetSubscribeAndListen(partyVM: viewModel, partyID: party.partyID)
        try await getMessages(viewModel: viewModel)

    }

    /// Retrieves all chat messages for the current party and updates the view model.
    /// - Parameter viewModel: The PartyViewModel instance to update with message data
    func getMessages(viewModel: PartyViewModel) async throws {
        guard let partyID = viewModel.currentParty?.partyID else { throw SharedErrors.general(error: .missingValue("Missing Party ID"))}

        let urlReq = try HTTP.GetReq.getMessages(partyID: partyID).createReq()
        let data = try await executeRequest(urlReq: urlReq)
        let response = try JSONDecoder().decode(MessagesGetResponse.self, from: data)
        let messages = try response.messages.map {
            guard let dateString = $0.date_created.fromPostgreSQLTimestamp() else
            {
                throw SharedErrors.general(error: .missingValue("Unable to convert date"))
            }
            return WSMessage(id: $0.id, text: $0.text, username: $0.user_name, timestamp: dateString, userID: $0.user_id)
        }


        viewModel.chatMessageList = messages
    }

    /// Fetches rated restaurants for the current party and updates the view model.
    /// - Parameter viewModel: The PartyViewModel instance to update with rated restaurant data
    func getRatedRestaurants(viewModel: PartyViewModel) async throws {
        guard let partyID = viewModel.currentParty?.partyID else { throw SharedErrors.general(error: .missingValue("Missing Party ID"))}
        let userID = try UserDefaultsWrapper.getUserID
        let urlReq = try HTTP.GetReq.ratedRestaurants(userID: userID, partyID: partyID).createReq()
        let data = try await executeRequest(urlReq: urlReq)
        let response = try JSONDecoder().decode(RatedRestaurantsGetResponse.self, from: data)

        viewModel.ratedRestaurants = response.ratedRestaurants
    }

}

//MARK: Utilities
extension Networking {

    /// Executes a URL request and returns response data, handling HTTP errors
    /// - Parameter urlReq: The URL request to execute
    /// - Returns: Response data if request succeeds
    /// - Throws: Network error or decoded API error from response
    private func executeRequest(urlReq: URLRequest) async throws -> Data {

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
            Log.error.log("Error executing request: \(error)")
            throw error
        }

    }

}
