//
//  PartyVM_Tests.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 8/8/25.
//

import Testing
import Foundation
import drinkdSharedModels
@testable import drinkd_iOS


@Suite("PartyViewModel Tests")
struct PartyVMTests {

//    @Test func clearAllRestaurants_Test() async throws {
//        var vm = PartyViewModel()
//        updateLocalRestaurants(vm: vm)
//
//        #expect(vm.localRestaurants.count == 1)
//        #expect(vm.localRestaurantsDefault.count == 1)
//
//        vm.clearAllRestaurants()
//
//        #expect(vm.localRestaurants.count == 0)
//        #expect(vm.localRestaurantsDefault.count == 0)
//    }

    @Test func updateLocalRestaurants_Test() {
        var vm = PartyViewModel()

        guard let businessProps =  Utilities.createBusinessSearchProperties() else {
            TestLog.error.log("Failed to create BusinessSearchProperties")
            return
        }

        vm.updateLocalRestaurants(in: [businessProps])

        #expect(vm.localRestaurants.count == 1)
        #expect(vm.localRestaurantsDefault.count == 1)

        #expect(vm.localRestaurants[0].deliveryAvailable == true)
        #expect(vm.localRestaurants[0].pickUpAvailable == true)
        #expect(vm.localRestaurants[0].reservationAvailable == nil)

    }

//    @Test func removeCardFromDeck_Test() {
//        var vm = PartyViewModel()
//        vm.removeCardFromDeck()
//        #expect(vm.currentCardIndex == 8)
//
//        vm.currentCardIndex = -1
//        vm.removeCardFromDeck()
//        #expect(vm.currentCardIndex == 9)
//    }

    @Test func addScoreToCard_Test() {
        var vm = PartyViewModel()
        updateLocalRestaurants(vm: vm)
//        vm.currentCardIndex = 0
        vm.addScoreToCard(points: 5)
        #expect(vm.currentScoreOfTopCard == 5)

//        let topBarRestaurant = vm.topBarList["0"]

//        #expect(topBarRestaurant?.name == "Alexander's Steakhouse")




    }

    @Test func leaveParty_Test() {
        var vm = PartyViewModel()
        vm.currentParty = Party(username: "", partyID: UUID(), partyMaxVotes: 1, partyName: "TEST PARTY", partyCode: 670, yelpURL: "3434")
        vm.topRestaurants.append(RatedRestaurantsTable(id: UUID(), partyID: UUID(), userID: UUID(), userName: "User", restaurantName: "restaurantName", rating: 5, imageURL: "TEST"))
        vm.chatMessageList.append(WSMessage(id: UUID(), text: "34", username: "DFGDFG", timestamp: Date(), userID: UUID()))

        #expect(vm.currentParty != nil)
        #expect(vm.topRestaurants.count == 1)
        #expect(vm.chatMessageList.count == 1)

        vm.leaveParty()

        #expect(vm.currentParty == nil)
        #expect(vm.topRestaurants.count == 0)
        #expect(vm.chatMessageList.count == 0)

    }

    @Test func testInitialVMData() {
        let vm = PartyViewModel()
        #expect(vm.customLat == 0)
        #expect(vm.customLong == 0)
        #expect(vm.currentParty == nil)
        #expect(vm.currentScoreOfTopCard == 0)
        #expect(vm.localRestaurants.count == 0)
        #expect(vm.localRestaurantsDefault.count == 0)
        #expect(vm.topRestaurants.count == 0)
        #expect(vm.chatMessageList.count == 0)
        #expect(vm.removeSplashScreen == true)
    }

    private func updateLocalRestaurants(vm: PartyViewModel) {
        guard let businessProps =  Utilities.createBusinessSearchProperties() else {
            TestLog.error.log("Failed to create BusinessSearchProperties")
            return
        }

        vm.localRestaurants.append(businessProps)
        vm.localRestaurantsDefault.append(businessProps)
    }

}
