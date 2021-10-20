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

	@State private var offset = CGSize.zero
	@EnvironmentObject var viewModel: drinkdViewModel
	let deviceIsPhone = UIDevice.current.userInterfaceIdiom == .phone

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
	init(in restaurantDetails: YelpApiBusinessSearchProperties, forView viewModel: drinkdViewModel) {
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

		self.optionsDelivery = restaurantDetails.deliveryAvailable ?? false
		self.optionsReservations = restaurantDetails.reservationAvailable ?? false
		self.optionsPickup = restaurantDetails.pickUpAvailable ?? false

	}

	var body: some View {

		GeometryReader { geo in

			let globalWidth = geo.frame(in: .global).width
			let globalHeight = geo.frame(in: .global).height

			ZStack {

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
//						.frame(maxHeight: 300)

					Group {
						HStack {
							Image(systemName: "house")
								.resizable()
								.scaledToFit()
								.frame(width: 40)
							Text("\(restaurantAddress1)  \n\(restaurantCity)")
								.padding([.leading], 10)

						}
						HStack {
							Image(systemName: "phone")
								.resizable()
								.scaledToFit()
								.frame(width: 40)
							Text("\(restaurantPhoneNumber)")
								.padding([.leading], 10)
						}
						//
						if (optionsPickup) {
							HStack {
								Image(systemName: "figure.walk")
									.resizable()
									.scaledToFit()
									.frame(width: 40)
								Text("Pickup Available")
									.padding([.leading], 10)
							}
						}
						if (optionsDelivery) {
							HStack {
								Image(systemName: "bicycle")
									.resizable()
									.scaledToFit()
									.frame(width: 40)
								Text("Delivery Available")
									.padding([.leading], 10)
							}
						}
						if (optionsReservations) {
							HStack {
								Image(systemName: "square.and.pencil")
									.resizable()
									.scaledToFit()
									.frame(width: 40)
								Text("Reservations Available")
									.padding([.leading], 10)
							}
						}
						//
					}
					if (viewModel.currentlyInParty) {
						HStack {
							Spacer()
							SubmitButton()
								.buttonStyle(deviceIsPhone ? CardInfoButton(deviceType: .phone) : CardInfoButton(deviceType: .ipad))
							YelpDetailButton(buttonName: "Get More Info", yelpURL: "\(restaurantURL)")
							Spacer()
						}

							HStack {
								Spacer()
								Group {
									Star( starValue: 1)
									Star( starValue: 2)
									Star( starValue: 3)
									Star( starValue: 4)
									Star( starValue: 5)
								}
								.scaledToFit()
								.frame(height: 50, alignment: .center)
								Spacer()
							}

					}

				}
				.padding(.all, CardPadding.mediumPadding.rawValue)
			}
			.rotationEffect(.degrees(Double(offset.width / 5 )))
			.offset(x: offset.width * 5, y: 0)
			.opacity(2 - Double(abs(offset.width / 50)))
			.gesture(
				DragGesture()
					.onChanged { gesture in
						self.offset = gesture.translation
					}

					.onEnded { _ in
						if abs(self.offset.width) > 100 {
							// remove the card
							viewModel.updateRestaurantList()
							viewModel.whenCardIsDraggedFromView()
							viewModel.setCurrentTopCardScoreToZero()
							viewModel.emptyTopBarList()

						} else {
							self.offset = .zero
						}
					}
			)
		}

	}

	private struct SubmitButton: View {

		@EnvironmentObject var viewModel: drinkdViewModel

		var body: some View {
			Button("Submit", action: {	viewModel.submitRestaurantScore()})
		}
	}

}

struct YelpDetailButton: View {
	@Environment(\.openURL) var openURL

	let deviceIsPhone = UIDevice.current.userInterfaceIdiom == .phone
	let buttonName: String
	let yelpURL: String
	

	var body: some View {
		Button {
			guard let url = URL(string: "\(yelpURL)") else {
				return print("BAD URL")
			}
			openURL(url)
		} label: {
			Text("\(buttonName)")
		}
		.buttonStyle(deviceIsPhone ? CardInfoButton(deviceType: .phone) : CardInfoButton(deviceType: .ipad))
	}
}


struct CardView_Previews: PreviewProvider {

	static var previews: some View {
		CardView(in: YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 56, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "454", location: YelpApiBusinessDetails_Location(address1: "4545", address2: "4545", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "test", display_phone: "test", distance: 6565.56), forView: drinkdViewModel())
	}

}
