//
//  YelpNetworking.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/2/21.
//

import Foundation
import drinkdSharedModels
import Vapor

protocol NetworkingProtocol {
    func fetchRestaurantsOnStartUp(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void)
    func fetchUsingCustomLocation(viewModel: PartyViewModel, longitude: Double, latitude: Double, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void)
    func fetchRestaurantsAfterJoiningParty(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void)
    func calculateTopThreeRestaurants(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void)
    func submitRestaurantScore(viewModel: PartyViewModel)
    func fetchExistingMessages(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void)
    func removeMessagingObserver(viewModel: PartyViewModel)
    func sendMessage(forMessage message: FireBaseMessage, viewModel: PartyViewModel )
    
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

    func fetchRestaurantsOnStartUp(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {

        //TODO: Issue where during reload there is a possibility to do a 2x call. Fix issue
        //Checks to see if the function already ran to prevent duplicate calls
        if (viewModel.localRestaurants.count > 0) {
            return
        }

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
            completionHandler(.failure(.noUserLocationFoundError))
            Log.networking.fault("ERROR - NO USER LOCATION FOUND ")
            return
        }

        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
            completionHandler(.failure(.invalidURLError))
            Log.networking.fault("ERROR - INVALID URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.token)", forHTTPHeaderField: "Authorization")


        //URLSession
        URLSession.shared.dataTask(with: request) { data, response, error in

            if error != nil {
                completionHandler(.failure(.generalNetworkError))
                Log.networking.fault("GENERAL NETWORK ERROR - \(error)")
                return
            }

            //If URLSession returns data, below code block will execute
            if let verifiedData = data {

                guard let JSONDecoderValue = try? JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData) else {
                    completionHandler(.failure(.decodingError))
                    Log.networking.fault("ERROR - DECODING ERROR")
                    return
                }
                //If you are here, the network should have fetched the data correctly.
                if let JSONArray = JSONDecoderValue.businesses {
                    DispatchQueue.main.async {

                        //                    viewModel.objectWillChange.send()
                        //Checks to see if the function already ran to prevent duplicate calls
                        //TODO: We do this because of the 2x networking call made. this prevents doubling up card stack
                        if (viewModel.localRestaurants.count <= 0) {
                            viewModel.appendDeliveryOptions(in: JSONArray)
                        }
                        completionHandler(.success(.connectionSuccess))
                        viewModel.currentParty?.url = url.absoluteString
                        viewModel.removeSplashScreen = true
                        self.userDeniedLocationServices = false
                    }
                }
            }
        }.resume()
    }
    //
    //Fetches a user defined location. Used when user disabled location services.
    func fetchUsingCustomLocation(viewModel: PartyViewModel, longitude: Double, latitude: Double, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {

        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
            completionHandler(.failure(.invalidURLError))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Constants.token)", forHTTPHeaderField: "Authorization")

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

                        completionHandler(.success(.connectionSuccess))
                        viewModel.appendDeliveryOptions(in: JSONArray)
                        viewModel.currentParty?.url = url.absoluteString
                        viewModel.removeSplashScreen = true
                        self.userDeniedLocationServices = false

                    }
                }
            }

        }.resume()

    }

    //Fetch restaurant after joining party
    func fetchRestaurantsAfterJoiningParty(viewModel: PartyViewModel, completionHandler: @escaping (Result<NetworkSuccess, NetworkErrors>) -> Void) {

        guard let verifiedPartyURL = viewModel.currentParty?.url else {
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
        request.setValue("Bearer \(Constants.token)", forHTTPHeaderField: "Authorization")

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

                        completionHandler(.success(.connectionSuccess))
                        viewModel.clearAllRestaurants()
                        viewModel.appendDeliveryOptions(in: JSONArray)
                    }
                }
            }

        }.resume()
    }
}

//MARK: Client -> Vapor Server code
extension Networking {

    func createParty(username: String) async throws -> RouteResponse {

        let urlString = HTTP.post(.createParty).fullURLString
        let urlRequest = try createPostRequest(reqType: .createParty, url: urlString, userName: username)
        let response =  try await postData(urlReq: urlRequest)
        UserDefaultsWrapper.setPartyID(id: response.currentPartyID)
        return response
    }

    func leaveParty(partyVM: PartyViewModel, partyID: UUID) async throws -> RouteResponse {

        let urlString = HTTP.post(.leaveParty).fullURLString
        let urlRequest = try createPostRequest(reqType: .leaveParty, url: urlString)
        await cancelWSConnection(partyVM: partyVM, partyID: partyID)
        return try await postData(urlReq: urlRequest)
    }

    func sendMessage(message: String, partyID: UUID) async throws -> RouteResponse {
        let urlString = HTTP.post(.sendMessage).fullURLString
        let urlReq = try createPostRequest(reqType: .sendMessage, url: urlString, partyID: partyID, message: message)
        return try await postData(urlReq: urlReq)
    }

    func addRating(partyID: UUID, userID: UUID, username: String, restaurantName: String, rating: Int) async throws -> RouteResponse {

        let urlString = HTTP.post(.updateRating).fullURLString
        let urlReq = try createPostRequest(reqType: .updateRating, url: urlString, partyID: partyID, userName: username, restaurantName: restaurantName, rating: rating)
        let response = try await postData(urlReq: urlReq)
        return response
    }

    private func createPostRequest(reqType: RequestTypes, url: String, partyID: UUID? = nil, partyCode: Int? = nil ,userName: String? = nil, message: String? = nil, restaurantName: String? = nil, rating: Int? = nil) throws -> URLRequest {

        guard let url = URL(string: url) else { throw SharedErrors.ClientNetworking.invalidURL }
        var urlRequest = URLRequest(url: url)
        guard let userID = UserDefaultsWrapper.getUserID() else { throw SharedErrors.general(error: .userDefaultsError("Unable to find user ID"))}
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")


        do {
            switch reqType {
            case .createParty:
                if let userName = userName {
                    urlRequest.httpBody = try JSONEncoder().encode(CreatePartyRequest(username: userName, userID: userID))
                }
            case .joinParty:
                if let partyCode = partyCode, let userName = userName {
                    urlRequest.httpBody = try JSONEncoder().encode(JoinPartyRequest(username: userName, partyCode: partyCode))
                }
            case .leaveParty:
                urlRequest.httpBody = try JSONEncoder().encode(LeavePartyRequest(userID: userID))

            case .sendMessage:
                if let message = message, let partyID = partyID {
                    urlRequest.httpBody = try JSONEncoder().encode(SendMessageRequest(userID: userID, partyID: partyID, message: message))
                }
            case .updateRating:
                if let partyID = partyID, let userName = userName, let userID = UserDefaultsWrapper.getUserID(), let restaurantName = restaurantName, let rating = rating  {
                    urlRequest.httpBody = try JSONEncoder().encode(UpdateRatingRequest(partyID: partyID, userID: userID, userName: userName, restaurantName: restaurantName, rating: rating))
                }
            }
        } catch {
            Log.networking.fault("Error encoding JSON - \(error)")
            throw error
        }

        return urlRequest
    }


    private func postData(urlReq: URLRequest) async throws -> RouteResponse {

        do {
            let (data, response) = try await URLSession.shared.data(for: urlReq)
            let httpResponse = response as! HTTPURLResponse

            if httpResponse.statusCode < 200 || httpResponse.statusCode > 200 {
                // Check if Error
                let error = try JSONDecoder().decode(ErrorWrapper.self, from: data)
                throw error.error
            }

            //Happy Path
            let partyRequest = try JSONDecoder().decode(RouteResponse.self, from: data)

            return partyRequest
        } catch {
            Log.networking.fault("Error posting data: \(error)")
            throw error
        }

    }

    //MARK: WebSocket code

    func connectToWebsocket(partyVM: PartyViewModel, username: String, partyID: UUID) async {

        do {

            try await WebSocket.connect(to: "ws://localhost:8080/testWS/\(username)/\(partyID.uuidString)") { ws in
                Log.networking.info("WebSocket connected to url - ws://localhost:8080/testWS/\(username)/\(partyID.uuidString)")

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
