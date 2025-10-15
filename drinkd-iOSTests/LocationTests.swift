//
//  LocationTests.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 9/6/25.
//

import drinkdSharedModels
import Testing
import CoreLocation
@testable import drinkd_iOS

struct LocationTests {

    @Test("Get a location using the users last known location")
    func getLocation_UseLastKnownLocation_Test() async throws {
        let vm = await PartyViewModel()
        let coordinates = CLLocationCoordinate2D(latitude: 37.507160, longitude: -122.260521)
        let fetcher = LocationFetcher()
        fetcher.lastKnownLocation = coordinates

        let location = try await fetcher.getLocation(partyVM: vm)
        #expect(location.coordinate.latitude == 37.507160)
        #expect(location.coordinate.longitude == -122.260521)
    }

    @Test("Get a location using the user inputted location")
    @MainActor
    func getLocation_UseUserInputtedLocation_Test() async throws {
        let vm =  PartyViewModel()
        vm.customLat = 37.507160
        vm.customLong = -122.260521

        let fetcher = LocationFetcher()

        let location = try fetcher.getLocation(partyVM: vm)
        #expect(location.coordinate.latitude == 37.507160)
        #expect(location.coordinate.longitude == -122.260521)
    }

    @Test("Get the user location with failure")
    @MainActor
    func getLocation_Fail_Test() async throws {
        let vm = PartyViewModel()
        let fetcher = LocationFetcher()

        #expect(throws: SharedErrors.self, performing: {
            try fetcher.getLocation(partyVM: vm)
        })

    }

}
