//
//  CardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

//245,31,32

import SwiftUI



struct CardView: View {

	private enum CardPadding: CGFloat{
		case smallPadding = 4
		case mediumPadding = 12
	}

	private enum TransactionTypes: String {
		case pickup
		case delivery
		case restaurant_reservation

	}

	var restaurantTitle: String
	var restaurantCategories: String
	var restaurantScore: Int
	var restaurantPrice: String
	var restaurantImage: String
	var restaurantCity: String
	var restaurantAddress1: String
	var restaurantAddress2: String?
	var restaurantPhoneNumber: String
	var restaurantZipCode: String
	var restaurantState: String
	var restaurantURL: String
	var optionsDelivery: Bool = false
	var optionsPickup: Bool = false
	var optionsReservations: Bool = false


	//We use optionals because the API can return null for some properties
	init(in restaurantDetails: YelpApiBusinessSearchProperties) {
		self.restaurantTitle = restaurantDetails.name ?? "Name not found"
		self.restaurantCategories = restaurantDetails.categories?[0].title ?? "None"
		self.restaurantScore = Int(restaurantDetails.rating ?? 0)
		self.restaurantPrice = restaurantDetails.price ?? "Not Found"
		self.restaurantImage = restaurantDetails.image_url ?? "Not Found"
		self.restaurantCity = restaurantDetails.location?.city ?? "Not Found"
		self.restaurantAddress1 = restaurantDetails.location?.address1 ?? "Not Found"
		self.restaurantAddress2 = restaurantDetails.location?.address2 ?? ""
		self.restaurantPhoneNumber  = restaurantDetails.phone ?? ""
		self.restaurantZipCode = restaurantDetails.location?.zip_code ?? ""
		self.restaurantState = restaurantDetails.location?.state ?? ""
		self.restaurantURL = restaurantDetails.url ?? ""

		let restaurantArray = restaurantDetails.transactions ?? [""]

		for element in restaurantArray {
			switch(element) {
			case TransactionTypes.pickup.rawValue:
				optionsPickup = true

			case TransactionTypes.delivery.rawValue:
				optionsDelivery = true

			case TransactionTypes.restaurant_reservation.rawValue:
				optionsReservations = true

			default:
				print("Nothing Found")
			}
		}

	}

	var body: some View {

		GeometryReader { geo in
			ZStack {
				let localWidth = geo.frame(in: .local).width
				let localHeight = geo.frame(in: .local).height

				RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
					.fill(Color.white)
					.shadow(radius: AppShadow.lowShadowRadius)

				VStack(alignment: .leading) {
					Text("\(restaurantTitle)")
						.font(.largeTitle)
					Text("\(restaurantCategories)")
						.font(.title2)
					Text("\(restaurantScore) / \(restaurantPrice)")
						.font(.title3)
					RemoteImageLoader(url: "\(restaurantImage)")
					//						.scaledToFit()
					//						.frame(width: localWidth, alignment: .center)
					Group {
						HStack {
							Image(systemName: "house")
								.resizable()
								.scaledToFit()
								.frame(width: 40)
							Text("\(restaurantAddress1)  \n\(restaurantCity)")

						}
						HStack {
							Image(systemName: "phone")
								.resizable()
								.scaledToFit()
								.frame(width: 40)
							Text("\(restaurantPhoneNumber)")
						}
						if (optionsPickup) {
							HStack {
								Image(systemName: "figure.walk")
									.resizable()
									.scaledToFit()
									.frame(width: 40)
								Text("Pickup Available")
							}
						}
						if (optionsDelivery) {
							HStack {
								Image(systemName: "bicycle")
									.resizable()
									.scaledToFit()
									.frame(width: 40)
								Text("Delivery Available")
							}
						}
						if (optionsReservations) {
							HStack {
								Image(systemName: "square.and.pencil")
									.resizable()
									.scaledToFit()
									.frame(width: 40)
								Text("Reservations Available")
							}
						}

					}
					HStack {
						Spacer()
						YelpDetailButton(buttonName: "Get More Info", yelpURL: "\(restaurantURL)")
						Spacer()
					}
					.padding(CardPadding.mediumPadding.rawValue)
				}
				.padding(.all, CardPadding.mediumPadding.rawValue)
			}
		}

	}
}

struct CardView_Previews: PreviewProvider {

	static var previews: some View {
		CardView(in: YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 56, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery, pickup"], price: "454", location: YelpApiBusinessDetails_Location(address1: "4545", address2: "4545", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "test", display_phone: "test", distance: 6565.56))
	}
}
