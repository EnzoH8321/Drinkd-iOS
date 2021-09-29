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
	}

	@ObservedObject var viewModel = drinkdViewModel()

	var restaurantTitle: String = ""
	var restaurantCategories: String = ""
	var restaurantScore: Double = 0.0
	var restaurantPrice: String = ""
	var restaurantImage: String = ""
	var restaurantCity: String = ""
	var restaurantAddress1: String = ""
	var restaurantAddress2: String? = ""
	var restaurantPhoneNumber: String = ""
	var restaurantZipCode: String = ""
	var restaurantState: String = ""

	init() {

	}

	var body: some View {

		GeometryReader { geo in
			ZStack {
				let localWidth = geo.frame(in: .local).width

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
					//						.resizable()
						.scaledToFit()
						.frame(width: localWidth - 30)
					Group {
						HStack {
							Image(systemName: "house")
								.resizable()
								.scaledToFit()
								.frame(width: 40)
							Text("""
\(restaurantAddress1)
\(restaurantCity)
""")
						}
						HStack {
							Image(systemName: "phone")
								.resizable()
								.scaledToFit()
								.frame(width: 40)
							Text("\(restaurantPhoneNumber)")
						}
					}
					HStack {
						Spacer()
						Button(action: {}) {
							Text("Sign In")
						}
						.buttonStyle(YelpDetailButton())
						.shadow(radius: AppShadow.mediumShadowRadius)
						Spacer()
					}


				}
				.padding(.all, CardPadding.smallPadding.rawValue)
			}
		}

	}
}

struct CardView_Previews: PreviewProvider {
	static var previews: some View {
		CardView()
	}
}
