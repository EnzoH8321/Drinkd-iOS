//
//  NetworkingTests.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 8/8/25.
//

import Testing
import CoreLocation
import drinkdSharedModels
@testable import drinkd_iOS

@Suite("Networking Tests")
struct NetworkingTests {

    // Core Location in Test uses the XCTEST Plan Location of SF (latitude: 37.7873589, longitude: -122.408227)
    private let sfLocation: CLLocationCoordinate2D

    init() {
        sfLocation = CLLocationCoordinate2D(latitude: 37.7873589, longitude: -122.408227)
    }

    @Test func updateUserDeniedLocationServices_Test()  {
        let networking = Networking()
        networking.updateUserDeniedLocationServices()
        #expect(networking.userDeniedLocationServices == false)
    }


    @Test("Updates restaurants based on user location via CoreLocation")
    func updateRestaurants_DefaultLocation_Test() async throws  {
        let networking = Networking()
        networking.locationFetcher.lastKnownLocation = sfLocation

        let vm = PartyViewModel()


       try await networking.updateRestaurants(viewModel: vm)
        #expect(vm.localRestaurants.count > 0)
        #expect(vm.localRestaurantsDefault.count > 0)
        #expect(vm.removeSplashScreen == true)
        #expect(networking.userDeniedLocationServices == false)
    }

    @Test("Updates restaurants, fails due to 0.0 longitude/latitude")
    func updateRestaurants_DefaultLocation_NoUserLocationFoundError_Test() async throws  {
        let networking = Networking()
        let vm = PartyViewModel()
        networking.locationFetcher.lastKnownLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        await #expect(throws: ClientNetworkErrors.noUserLocationFoundError) {
            try await networking.updateRestaurants(viewModel: vm)
        }
    }

    @Test("Updates restaurants based on custom location")
    func updateRestaurants_CustomLocation_Test() async throws  {
        let vm = PartyViewModel()
        let networking = Networking()
        try await networking.updateRestaurants(viewModel: vm, longitude: sfLocation.longitude, latitude: sfLocation.latitude)
        #expect(vm.localRestaurants.count > 0)
        #expect(vm.localRestaurantsDefault.count > 0)
        #expect(vm.removeSplashScreen == true)
        #expect(networking.userDeniedLocationServices == false)
    }

    @Test("Updates restaurants, fails due to 0.0 longitude/latitude")
    func updateRestaurants_CustomLocation_NoUserLocationFoundError_Test() async throws  {
        let vm = PartyViewModel()
        let networking = Networking()
        await #expect(throws: ClientNetworkErrors.noUserLocationFoundError) {
            try await networking.updateRestaurants(viewModel: vm, longitude: 0.0, latitude: 0.0)
        }
    }

    @Test("Get restaurants with the provided coordinates")
    func getRestaurants_Coordinates_Test() async throws {
        let networking = Networking()
        let businessSearch = try await networking.getRestaurants(latitude: sfLocation.latitude, longitude: sfLocation.longitude)
        #expect(!businessSearch.businesses!.isEmpty)
    }

    @Test("Get restaurants with the provided url string")
    func getRestaurants_URLString_Test() async throws {
        let networking = Networking()
        let urlString = "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(sfLocation.latitude)&longitude=\(sfLocation.longitude)&limit=10"
        let businessSearch = try await networking.getRestaurants(yelpURL: urlString)
        #expect(!businessSearch.businesses!.isEmpty)
    }

    @Test("Get restaurants with the provided url string, Fails with ClientNetworkErrors.invalidURLError")
    func getRestaurants_URLString_InvalidURLError_Test() async throws {

        let networking = Networking()
        // Test for different url strings
        let urlString = ""
       await  #expect(throws: ClientNetworkErrors.invalidURLError, performing: {
            try await networking.getRestaurants(yelpURL: urlString)
        })

    }

    @Test("Create a party")
    func createParty() async throws {
        let networking = Networking()
        let vm = PartyViewModel()
        let username = "Guest001"
        let partyName = "Party001"
        let restaurantsURL = "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(sfLocation.latitude)&longitude=\(sfLocation.longitude)&limit=10"

        try await networking.createParty(viewModel: vm, username: username, partyName: partyName, restaurantsURL: restaurantsURL)

        let party = #require(vm.currentParty)
        #expect(party.username == username)
        #expect(party.partyName == partyName)
        #expect(party.yelpURL == restaurantsURL)
        #expect(party.partyMaxVotes == 0)

    }


}

