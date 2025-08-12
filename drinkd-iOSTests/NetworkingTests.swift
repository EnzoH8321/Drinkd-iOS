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

//    var vm: PartyViewModel
    // Core Location in Test uses the XCTEST Plan Location of SF (latitude: 37.7873589, longitude: -122.408227)
    private let sfLocation: CLLocationCoordinate2D

    init() {
        self.sfLocation = CLLocationCoordinate2D(latitude: 37.7873589, longitude: -122.408227)
    }



    @Test func updateUserDeniedLocationServices_Test()  {
        Networking.shared.updateUserDeniedLocationServices()
        #expect(Networking.shared.userDeniedLocationServices == false)
    }


    @Test("Updates restaurants based on user location via CoreLocation")
    func updateRestaurants_DefaultLocation_Test() async throws  {
        let lastKnownLocation = try #require(Networking.shared.locationFetcher.lastKnownLocation)
        let vm = PartyViewModel()


       try await Networking.shared.updateRestaurants(viewModel: vm)
        #expect(vm.localRestaurants.count > 0)
        #expect(vm.localRestaurantsDefault.count > 0)
        #expect(vm.removeSplashScreen == true)
        #expect(Networking.shared.userDeniedLocationServices == false)
    }

    @Test("Updates restaurants, fails due to 0.0 longitude/latitude")
    func updateRestaurants_DefaultLocationZeroLocation_Test() async throws  {
        let vm = PartyViewModel()
        Networking.shared.locationFetcher.lastKnownLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        await #expect(throws: ClientNetworkErrors.noUserLocationFoundError) {
            try await Networking.shared.updateRestaurants(viewModel: vm)
        }
    }

    @Test("Updates restaurants based on custom location")
    func updateRestaurants_CustomLocation_Test() async throws  {
        let vm = PartyViewModel()
        try await Networking.shared.updateRestaurants(viewModel: vm, longitude: sfLocation.longitude, latitude: sfLocation.latitude)
        #expect(vm.localRestaurants.count > 0)
        #expect(vm.localRestaurantsDefault.count > 0)
        #expect(vm.removeSplashScreen == true)
        #expect(Networking.shared.userDeniedLocationServices == false)
    }
}


