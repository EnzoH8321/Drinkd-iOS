//
//  drinkdViewModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import Foundation
import SwiftUI
import drinkdSharedModels

@Observable
class PartyViewModel {

    var customLat: Double = 0
    var customLong: Double = 0

    var currentParty: Party?

    var currentScoreOfTopCard: Int = 0
    //Represents Deck
    var localRestaurants: [YelpApiBusinessSearchProperties] = []
    //
    var localRestaurantsDefault: [YelpApiBusinessSearchProperties] = []

    // Top Restaurants
    var topRestaurants: [RatedRestaurantsTable] = []

    var chatMessageList: [WSMessage] = []

    var removeSplashScreen = true

    var currentlyInParty: Bool {
        return currentParty != nil ? true : false
    }

    /// Updates service availability values
    /// - Parameter restaurants: Restaurant data
    func updateLocalRestaurants(in restaurants: [YelpApiBusinessSearchProperties]) {

        for var element in restaurants {
            // Get available transaction types, use empty array if none provided
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


    /// Updates the score of the top card with the provided points value.
    /// If the new points value is the same as the current score, no update occurs.
    /// - Parameter points: The new score value to assign to the top card

    func addScoreToCard(points: Int) {

        if (points == currentScoreOfTopCard) {
            return
        }

        self.currentScoreOfTopCard = points
    }

    /// Exits the current party session and resets all party-related data
    func leaveParty() {
        self.topRestaurants.removeAll()
        currentParty = nil
        chatMessageList.removeAll()
    }

}

