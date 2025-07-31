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

    var customLat: Double = 0
    var customLong: Double = 0

    private var currentCardIndex: Int = 9
    var currentParty: Party?

    var topBarList: [String: restaurantScoreInfo] = [:]
    var currentScoreOfTopCard: Int = 0
    //Represents Deck
    var localRestaurants: [YelpApiBusinessSearchProperties] = []
    //
    var localRestaurantsDefault: [YelpApiBusinessSearchProperties] = []

    // Top Restaurants
    var topRestaurants: [RatedRestaurantsTable] = []

    var chatMessageList: [WSMessage] = []

    var removeSplashScreen = true

    // WebSocket
    var currentWebsocket: WebSocket? = nil

    var currentlyInParty: Bool {
        return currentParty != nil ? true : false
    }

    //Used when a party is joined
    func clearAllRestaurants() {
        self.localRestaurants.removeAll()
        self.localRestaurantsDefault.removeAll()
    }

    //Checks to see if the transaction array exists. if it does, parse it and fill the needed transaction properties
    func updateLocalRestaurants(in restaurants: [YelpApiBusinessSearchProperties]) {

        for var element in restaurants {
            let transactionArray = element.transactions ?? [""]

            if (transactionArray.contains("pickup")) {
                element.pickUpAvailable = true
            }
            if (transactionArray.contains("delivery")) {
                element.deliveryAvailable = true
            }
            if (transactionArray.contains("restaurant_reservation")) {
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

    func addScoreToCard(points: Int) {

        if (points == currentScoreOfTopCard) {
            return
        }

        self.currentScoreOfTopCard = points

        topBarList["\(currentCardIndex)"] = restaurantScoreInfo(name: localRestaurantsDefault[currentCardIndex].name ?? "Not Found", score: points, url: self.currentParty?.yelpURL ?? "URL NOT FOUND")
    }

    func leaveParty() {        
        self.topRestaurants.removeAll()
        currentParty = nil
        chatMessageList.removeAll()
    }

}

