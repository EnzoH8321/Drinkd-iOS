//
//  ListCardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI
import Foundation

//Allows you to sepcify which corner will have the radius
struct CornerRadiusStyle: ViewModifier {
	var radius: CGFloat
	var corners: UIRectCorner

	struct CornerRadiusShape: Shape {

		var radius = CGFloat.infinity
		var corners = UIRectCorner.allCorners

		func path(in rect: CGRect) -> Path {
			let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
			return Path(path.cgPath)
		}
	}

	func body(content: Content) -> some View {
		content
			.clipShape(CornerRadiusShape(radius: radius, corners: corners))
	}
}
//Extends the custom struct to the View
extension View {
	func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
		ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
	}
}
//
struct ListCardView: View {

	var restaurantInfo: FirebaseRestaurantInfo

	var body: some View {

		GeometryReader { proxy in

			let globalWidth = proxy.frame(in: .global).width
			let globalHeight = proxy.frame(in: .global).height

			ZStack {
				RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
					.fill(Color.white)
					.shadow(radius: AppShadow.lowShadowRadius)
				VStack {

					Image("testPicRestaurant")
						.resizable()
						.frame(width: globalWidth )
						.cornerRadius(radius: CardSpecificStyle.cornerRadius, corners: [.topLeft, .topRight])

					HStack {
						Image(systemName: "1.circle")
							.resizable()
							.scaledToFit()
							.frame(width: 25)
						Spacer()
						VStack{
							Text("Restaurant Name")
							Text("Number of Votes")
						}
					}
					.padding([.leading, .trailing], globalWidth / 4)

				}

			}
			.frame(width: globalWidth, height: globalHeight, alignment: .center)
		}
	}
}

struct ListCardView_Previews: PreviewProvider {
	static var previews: some View {
		ListCardView(restaurantInfo: FirebaseRestaurantInfo(name: "TEST", score: 10, url: "https://www.yelp.com/biz/gary-danko-san-francisco?adjust_creative=wpr6gw4FnptTrk1CeT8POg&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_lookup&utm_source=wpr6gw4FnptTrk1CeT8POg", image_url: "WavvLdfdP6g8aZTtbBQHTw"))
	}
}
