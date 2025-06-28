//
//  drinkdViewModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import Foundation
import SwiftUI
import drinkdSharedModels
import Vapor

@Observable
class PartyViewModel {

    private enum TransactionTypes: String {
        case pickup
        case delivery
        case restaurant_reservation
    }

    private enum userLevel: String {
        case creator
        case member
    }

    var personalUserName = ""
    var personalUserID: UUID?

    var fcmToken: String = ""
    var currentCardIndex: Int = 9
    var currentlyInParty = false
    var currentParty: Party?
    //Id for someone elses party
    var friendPartyId: String?
    var isPartyLeader: Bool = false
    var topBarList: [String: restaurantScoreInfo] = [:]
    var currentScoreOfTopCard: Int = 0
    //Represents Deck
    var localRestaurants: [YelpApiBusinessSearchProperties] = []
    //
    var localRestaurantsDefault: [YelpApiBusinessSearchProperties] = []

    // Top Restaurants
    var topRestaurants: [RatedRestaurantsTable] = []

    var chatMessageList: [WSMessage] = []
    //
    var queryPartyError = false
    var removeSplashScreen = true

    // WebSocket
    var currentWebsocket: WebSocket? = nil

    //Used when a party is joined
    func clearAllRestaurants() {
        self.localRestaurants.removeAll()
        self.localRestaurantsDefault.removeAll()
    }

    //Checks to see if the transaction array exists. if it does, parse it and fill the needed transaction properties
    func appendDeliveryOptions(in restaurants: [YelpApiBusinessSearchProperties]) {

        for var element in restaurants {
            let transactionArray = element.transactions ?? [""]

            if (transactionArray.contains(TransactionTypes.pickup.rawValue)) {
                element.pickUpAvailable = true
            }
            if (transactionArray.contains(TransactionTypes.delivery.rawValue)) {
                element.deliveryAvailable = true
            }
            if (transactionArray.contains(TransactionTypes.restaurant_reservation.rawValue)) {
                element.reservationAvailable = true
            }

            localRestaurants.append(element)
            localRestaurantsDefault.append(element)
        }
    }

    func removeCardFromDeck() {

        self.currentCardIndex -= 1

        if (self.currentCardIndex < 0) {
            self.currentCardIndex = 9
        }
    }

    func createParty(leaderID: String ,setVotes partyVotes: Int, setName partyName: String) {

        self.fcmToken = AppDelegate.fcmToken
        currentParty?.partyID = String(Int.random(in: 100...20000))
        self.currentParty?.partyMaxVotes = partyVotes
        currentParty?.partyName = partyName
        currentParty?.timestamp = Int(Date().timeIntervalSince1970 * 1000)

        guard let party = self.currentParty else { return }

        //TODO: Messages set to string, can this be improved?
        self.setUserLevel(level: .creator)
        self.currentlyInParty = true
    }

    func joinParty( getVotes votes: Int? = nil,  getURL url: String? = nil) {

        guard let validFriendPartyId = self.friendPartyId else { return }

        if let partyVotes = votes {
            currentParty?.partyMaxVotes = partyVotes
        }

        if let siteURL = url {
            currentParty?.url = siteURL
        }

    }

    func addScoreToCard(points: Int) {

        if (points == currentScoreOfTopCard) {
            return
        }

        self.currentScoreOfTopCard = points

        topBarList["\(currentCardIndex)"] = restaurantScoreInfo(name: localRestaurantsDefault[currentCardIndex].name ?? "Not Found", score: points, url: self.currentParty?.url ?? "URL NOT FOUND")
    }

    private func setUserLevel(level: userLevel) {
        switch (level) {
        case .member:
            self.isPartyLeader = false
        case .creator:
            self.isPartyLeader = true
        }
    }

    func leaveParty() {
        self.currentlyInParty = false
        self.topRestaurants.removeAll()
        currentParty = nil
        currentParty?.partyID = ""
    }

    //For chat
    //TODO: Finish Chat Features
    func setPersonalUserAndID(forName name: String, forID id: UUID) {
        self.personalUserName = name
        self.personalUserID = id
    }
}

