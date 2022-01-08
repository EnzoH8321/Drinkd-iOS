//
//  NetworkingYelp.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import CoreLocation

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
		print("Error -> \(error.localizedDescription)")
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
			print("Unknown Default")
		}
	}

	
}


