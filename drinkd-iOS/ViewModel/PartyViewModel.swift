//
//  drinkdViewModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import Foundation
import SwiftUI
import Firebase

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

    var fcmToken: String = ""
    var currentCardIndex: Int = 9
    var currentlyInParty = false
    var partyId: String?
    var partyMaxVotes: Int?
    var partyName: String?
    var partyTimestamp: Int?
    var partyURL: String?
    //Id for someone elses party
    var friendPartyId: String?
    var isPartyLeader: Bool = false
    var topBarList: [String: restaurantScoreInfo] = [:]
    var currentScoreOfTopCard: Int = 0
    //Represents Deck
    var localRestaurants: [YelpApiBusinessSearchProperties] = []
    //
    var localRestaurantsDefault: [YelpApiBusinessSearchProperties] = []
    //For top choices view
    var firstChoice = FirebaseRestaurantInfo()
    var secondChoice = FirebaseRestaurantInfo()
    var thirdChoice = FirebaseRestaurantInfo()

    var chatVM = ChatViewModel()
    //
    var queryPartyError = false
    var removeSplashScreen = true

    private enum FireBasePartyProps: String {
        case partyID, partyMaxVotes, partyName, partyTimestamp, partyURL
    }

    //called when the create party button in the create party screen in pushed
    func createNewParty(setVotes partyVotes: Int? = nil, setName partyName: String? = nil) {
        createParty(setVotes: partyVotes, setName: partyName)
        self.currentlyInParty = true
    }

    func JoinExistingParty(getCode partyCode: String) {

        let topBarsReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(partyCode)")

        //Reads data at a path and listens for changes
        topBarsReference.getData(completion: { error, snapshot in

            if let validSnapshot = snapshot {
                if(!validSnapshot.exists()) {
                    self.queryPartyError = true
                    print("Party does not exist")
                    print(self.queryPartyError)
                    return
                } else {

                    //Organizes values into a usable swift object
                    guard let value = validSnapshot.value as? [String: AnyObject] else {
                        print("Value cannot be unwrapped to a Swift readable format ")
                        return
                    }
                    for (key, valueProperty) in value {
                        switch key {
                        case FireBasePartyProps.partyID.rawValue:
//                            self.setFriendsPartyId(code: valueProperty as? String)
                            self.friendPartyId = valueProperty as? String
                        case FireBasePartyProps.partyMaxVotes.rawValue:
                            self.joinParty(getVotes: valueProperty as? Int)

                        case FireBasePartyProps.partyName.rawValue:
//                            self.setPartyName(name: valueProperty as? String)
                            self.partyName = valueProperty as? String
                        case FireBasePartyProps.partyURL.rawValue:
                            self.joinParty(getURL: valueProperty as? String)

                        default:
                            continue
                        }
                    }

                    self.setUserLevel(level: .member)
                    self.partyId = String(Int.random(in: 100...20000))
                    self.currentlyInParty = true
                    self.queryPartyError = false
                }
            }


        })
    }

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

    func createParty(setVotes partyVotes: Int? = nil, setName partyName: String? = nil, setURL partyURL: String? = nil) {

        self.fcmToken = AppDelegate.fcmToken
        self.partyId = String(Int.random(in: 100...20000))
        self.partyMaxVotes = partyVotes
        self.partyName = partyName
        self.partyTimestamp = Int(Date().timeIntervalSince1970 * 1000)

        guard let partyID = self.partyId, let partyMaxVotes = self.partyMaxVotes, let partyName = self.partyName, let partyTimestamp = self.partyTimestamp, let partyURL = self.partyURL  else {
            return
        }

        //TODO: Messages set to string, can this be improved?
        Constants.ref.child("parties").child(partyID).setValue(["partyTimestamp": partyTimestamp, "partyID": partyID, "partyMaxVotes": partyMaxVotes, "partyName": partyName, "partyURL": partyURL, "tokens": [fcmToken: fcmToken]])
        self.setUserLevel(level: .creator)

    }

    func joinParty( getVotes votes: Int? = nil,  getURL url: String? = nil) {

        guard let validFriendPartyId = self.friendPartyId else { return }

        if let partyVotes = votes {
            self.partyMaxVotes = partyVotes
        }

        if let siteURL = url {
            self.partyURL = siteURL
        }

        Constants.ref.child("parties").child(validFriendPartyId).child("tokens").updateChildValues([fcmToken: fcmToken])
    }

    func addScoreToCard(points: Int) {

        if (points == currentScoreOfTopCard) {
            return
        }

        self.currentScoreOfTopCard = points

        topBarList["\(currentCardIndex)"] = restaurantScoreInfo(name: localRestaurantsDefault[currentCardIndex].name ?? "Not Found", score: points, url: self.partyURL ?? "URL NOT FOUND")
    }

    func appendTopThreeRestaurants(in array: [Dictionary<String, FireBaseTopChoice>.Element]) {
        //Empties Elements
        firstChoice = FirebaseRestaurantInfo()
        secondChoice = FirebaseRestaurantInfo()
        thirdChoice = FirebaseRestaurantInfo()

        for element in 0..<array.count {

            switch (element) {
            case 0:
                let firstElementValues = array[0].value
                let firstElementKey = array[0].key
                firstChoice = FirebaseRestaurantInfo(name: firstElementKey, score: firstElementValues.score, url: firstElementValues.url, image_url: firstElementValues.image_url)
            case 1:
                let secondElementValues = array[1].value
                let secondIndexKey = array[1].key
                secondChoice = FirebaseRestaurantInfo(name: secondIndexKey, score: secondElementValues.score, url: secondElementValues.url, image_url: secondElementValues.image_url)
            case 2:
                let thirdElementValues = array[2].value
                let thirdKey = array[2].key
                thirdChoice = FirebaseRestaurantInfo(name: thirdKey, score: thirdElementValues.score, url: thirdElementValues.url, image_url: thirdElementValues.image_url)
            default:
                break
            }
        }
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
        self.firstChoice = FirebaseRestaurantInfo()
        self.secondChoice = FirebaseRestaurantInfo()
        self.thirdChoice = FirebaseRestaurantInfo()
        self.partyId = ""
    }

    func removeImageUrls(){
        self.firstChoice.image_url = ""
        self.secondChoice.image_url = ""
        self.thirdChoice.image_url = ""
    }
}

