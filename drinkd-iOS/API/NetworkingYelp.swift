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
	}
}

func fetchNearbyPlaces(setLatitude latitude: Double, setLongitude longitude: Double) {
	//1.Creating the URL we want to read.
	//2.Wrapping that in a URLRequest, which allows us to configure how the URL should be accessed.
	//3.Create and start a networking task from that URL request.
	//4.Handle the result of that networking task.

	//DELETE FOR RELEASE!
	let token = "nX9W-jXWsXSB_gW3t2Y89iwQ-M7SR9-HVBHDAqf1Zy0fo8LTs3Q1VbIVpdeyFu7PehJlkLDULQulnJ3l6q6loIET5JHmcs9i3tJqYEO02f39qKgSCi4DAEVIlgPPX3Yx"

	guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=\(latitude)&longitude=\(longitude)&limit=10") else {
		print("Invalid URL")
		return
	}

	var request = URLRequest(url: url)
	request.httpMethod = "GET"
	request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")


	URLSession.shared.dataTask(with: request) { data, response, error in

		//Closure
		guard let verifiedData = data else {
			return
		}

		do {
			let JSONDecoder = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData)
			DispatchQueue.main.async {
				// update our UI
				print(JSONDecoder)
			}

		} catch {
			print(error )
		}

	}.resume()
}
