//
//  Networking.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/8/25.
//
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class SharedNetworking {
    @MainActor public static let shared = SharedNetworking()
    private init() { }
}

public enum HTTP {
    case get(GetRoutes)
    case post(PostRoutes)
    case delete

    private var baseURLString: String { "http://127.0.0.1:8080/" }

    public enum PostRoutes: String, CaseIterable {
        case createParty
        case joinParty
        case leaveParty
        case sendMessage
        case updateRating

        // Post Req
        private func buildPostReq(url: String) throws -> URLRequest {
            guard let url = URL(string: url) else { throw ClientNetworkErrors.invalidURLError }
            var urlRequest = URLRequest(url: url)

            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            return urlRequest
        }

        public func createPartyReq(userID: UUID, userName: String, restaurantsUrl: String, partyName: String) throws -> URLRequest {
            do {
                var baseReq = try buildPostReq(url: HTTP.post(.createParty).fullURLString)
                baseReq.httpBody = try JSONEncoder().encode(CreatePartyRequest(username: userName, userID: userID, restaurants_url: restaurantsUrl, partyName: partyName))
                return baseReq
            } catch {
                Log.networking.error("Error encoding JSON when creating a party - \(error)")
                throw error
            }

        }

        public func joinPartyReq(userID: UUID, partyCode: Int, userName: String) throws -> URLRequest {
            do {
                var baseReq = try buildPostReq(url: HTTP.post(.joinParty).fullURLString)
                baseReq.httpBody = try JSONEncoder().encode(JoinPartyRequest(userID: userID, username: userName, partyCode: partyCode))
                return baseReq
            } catch {
                Log.networking.error("Error encoding JSON when joining a party - \(error)")
                throw error
            }
        }

        public func leavePartyReq(userID: UUID) throws -> URLRequest {
            do {
                var baseReq = try buildPostReq(url: HTTP.post(.leaveParty).fullURLString)
                baseReq.httpBody = try JSONEncoder().encode(LeavePartyRequest(userID: userID))
                return baseReq
            } catch {
                Log.networking.error("Error encoding JSON when leaving a party - \(error)")
                throw error
            }
        }

        public func sendMsgReq(userID: UUID, username: String, message: String, partyID: UUID) throws -> URLRequest {
            do {
                var baseReq = try buildPostReq(url: HTTP.post(.sendMessage).fullURLString)
                baseReq.httpBody = try JSONEncoder().encode( SendMessageRequest(userID: userID, username: username, partyID: partyID, message: message) )
                return baseReq
            } catch {
                Log.networking.error("Error encoding JSON when sending a message - \(error)")
                throw error
            }
        }

        public func updateRatingReq(partyID: UUID,  userName: String ,  userID: UUID,  restaurantName: String, rating: Int,  imageuRL: String) throws -> URLRequest {
            do {
                var baseReq = try buildPostReq(url: HTTP.post(.updateRating).fullURLString)
                baseReq.httpBody = try JSONEncoder().encode( UpdateRatingRequest(partyID: partyID, userID: userID, userName: userName, restaurantName: restaurantName, rating: rating, imageURL: imageuRL))
                return baseReq
            } catch {
                Log.networking.error("Error encoding JSON when updating a rating - \(error)")
                throw error
            }
        }

    }

    public enum GetRoutes: String, CaseIterable {
        case topRestaurants
        case rejoinParty
        case getMessages

        // Get Req
        private func buildGetReq(url: String) throws -> URLRequest {
            guard let url = URL(string: url) else { throw ClientNetworkErrors.invalidURLError }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            return urlRequest
        }

        public func rejoinPartyReq(userID: String, url: String) throws -> URLRequest {
            var urlReq = try buildGetReq(url: url)

            if var components = URLComponents(string: url) {
                components.queryItems = [URLQueryItem(name: "userID", value: userID)]
                urlReq.url = components.url
            } else {
                Log.networking.error("Unable to create URLComponents")
            }
            return urlReq
        }

        public func topRestaurantsReq(partyID: UUID,  url: String) throws -> URLRequest {
            var urlReq = try buildGetReq(url: url)

            if var components = URLComponents(string: url) {
                components.queryItems = [URLQueryItem(name: "partyID", value: partyID.uuidString)]
                urlReq.url = components.url
            } else {
                Log.networking.error("Unable to create URLComponents or PartyID")
            }

            return urlReq
        }

        public func getMessagesReq(partyID: UUID, url: String) throws -> URLRequest {
            var urlReq = try buildGetReq(url: url)

            if var components = URLComponents(string: url) {
                components.queryItems = [URLQueryItem(name: "partyID", value: partyID.uuidString)]
                urlReq.url = components.url
            } else {
                Log.networking.error("Unable to create URLComponents or PartyID")
            }

            return urlReq
        }
    }

    public var fullURLString: String {
        switch self {
        case .get(let getRoutes):
            return baseURLString + getRoutes.rawValue
        case .post(let postRoutes):
           return baseURLString + postRoutes.rawValue
        case .delete:
            return baseURLString
        }
    }
}
