//
//  drinkdViewModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import Foundation
import SwiftUI

class drinkdViewModel: ObservableObject {
	@State var removeSplashScreen = false
	@Published var model = drinkdModel()

	init() {
			//1.Creating the URL we want to read.
			//2.Wrapping that in a URLRequest, which allows us to configure how the URL should be accessed.
			//3.Create and start a networking task from that URL request.
			//4.Handle the result of that networking task.

			//DELETE FOR RELEASE!
			let token = "nX9W-jXWsXSB_gW3t2Y89iwQ-M7SR9-HVBHDAqf1Zy0fo8LTs3Q1VbIVpdeyFu7PehJlkLDULQulnJ3l6q6loIET5JHmcs9i3tJqYEO02f39qKgSCi4DAEVIlgPPX3Yx"

			var longitude: Double = 0.0
			var latitude: Double = 0.0
			let locationFetcher = LocationFetcher()

			locationFetcher.start()

			if let location = locationFetcher.lastKnownLocation {
				latitude = location.latitude
				longitude = location.longitude
			}

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
					let JSONDecoderValue = try JSONDecoder().decode(YelpApiBusinessSearch.self, from: verifiedData)
					self.model.localRestaurants = JSONDecoderValue
					print(JSONDecoderValue)

				} catch {
					print(error )
				}

			}.resume()

		}
	}


