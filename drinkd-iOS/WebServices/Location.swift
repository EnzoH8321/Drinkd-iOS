//
//  NetworkingYelp.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import CoreLocation
import drinkdSharedModels

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {

	private let manager = CLLocationManager()
	var lastKnownLocation: CLLocationCoordinate2D?
	private(set) var errorWithLocationAuth = false

	override init() {
		super.init()
		manager.delegate = self
	}

	func requestWhenInUseAuthorization() {
		manager.requestWhenInUseAuthorization()
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		lastKnownLocation = locations.first?.coordinate
        self.errorWithLocationAuth = false
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        guard let clError = error as? CLError else {
            Log.error.log("Error: \(error.localizedDescription)")
            self.errorWithLocationAuth = true
            return
        }

        // According to the CLLocationManagerDelegate docs, error code of `locationUnknown` can be ignored in order to wait for a new event
        switch clError.code {
        case .locationUnknown:
            break
        case .denied:
            Log.general.log("User has denied location access: CL Error Code: \(clError.code.rawValue)")
            self.errorWithLocationAuth = true
        default:
            Log.general.log("CL Error Code: \(clError.code.rawValue)")
            self.errorWithLocationAuth = true
        }

	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

		switch manager.authorizationStatus {
		case .authorized, .authorizedWhenInUse, .authorizedAlways:
			self.errorWithLocationAuth = false
            manager.startUpdatingLocation()

        case .notDetermined:
            self.errorWithLocationAuth = true
            manager.requestWhenInUseAuthorization()

		case .denied, .restricted:
			self.errorWithLocationAuth = true
		@unknown default:
            Log.general.log("locationManagerDidChangeAuthorization: Unknown Default")
            // We should not even get to here, but in the off chance the default will be an error w/ location authorization
            self.errorWithLocationAuth = true
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


