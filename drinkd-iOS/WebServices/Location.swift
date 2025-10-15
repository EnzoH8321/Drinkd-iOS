//
//  NetworkingYelp.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import CoreLocation
import drinkdSharedModels

class LocationFetcher: NSObject, CLLocationManagerDelegate {
	let manager = CLLocationManager()
	var lastKnownLocation: CLLocationCoordinate2D?
	private(set) var errorWithLocationAuth = false

	override init() {
		super.init()
		manager.delegate = self
	}

	func start() {
		manager.requestWhenInUseAuthorization()
		manager.startUpdatingLocation()
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		lastKnownLocation = locations.first?.coordinate
        self.errorWithLocationAuth = false
      
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.error.log("Error -> \(error.localizedDescription)")
		self.errorWithLocationAuth = true
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		let authorization = manager.authorizationStatus

		switch (authorization) {
		case .authorized,
				.authorizedWhenInUse,
				.authorizedAlways:
			self.errorWithLocationAuth = false
			
		case .denied,
				.notDetermined,
				.restricted:
			self.errorWithLocationAuth = true
		@unknown default:
            Log.general.log("Unknown Default")
		}
	}

    /// Retrieves the user's current location with fallback options.
    ///
    /// This function attempts to get a valid location using a priority system:
    /// 1. Device's last known GPS location (if available)
    /// 2. Custom coordinates from the party view model (if set)
    ///
    /// - Parameter partyVM: The PartyViewModel containing custom location coordinates
    /// - Returns: A CLLocation object representing the user's position
    /// - Throws: SharedErrors.general if no valid location can be determined
    @MainActor
    func getLocation(partyVM: PartyViewModel) throws -> CLLocation {
        if let lastKnownLocation {
            return CLLocation(latitude: lastKnownLocation.latitude, longitude: lastKnownLocation.longitude)
        }

        if partyVM.customLat != 0 && partyVM.customLong != 0 {
            return CLLocation(latitude: partyVM.customLat, longitude: partyVM.customLong)
        }

        throw SharedErrors.general(error: .missingValue("Unable to retrieve the current location"))
    }

}


