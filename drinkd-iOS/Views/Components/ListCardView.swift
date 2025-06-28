//
//  ListCardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI
import Foundation
import drinkdSharedModels

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

	var restaurantInfo: RatedRestaurantsTable
	var placementImage: String

	init(restaurantInfo: RatedRestaurantsTable, placementImage: Int) {
		self.restaurantInfo = restaurantInfo

		switch (placementImage) {
		case 1:
			self.placementImage = "1.circle"
		case 2:
			self.placementImage = "2.circle"
		case 3:
			self.placementImage = "3.circle"
		default:
			self.placementImage = "xmark.octagon"
		}
		
	}

	var body: some View {

		GeometryReader { proxy in

			let globalWidth = proxy.frame(in: .global).width
			let globalHeight = proxy.frame(in: .global).height

			ZStack {
				RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
					.fill(Color.white)
					.shadow(radius: AppShadow.lowShadowRadius)
				HStack {

					RemoteImageLoader(url: "\(restaurantInfo.image_url)")
                        .cornerRadius(radius: CardSpecificStyle.cornerRadius, corners: [.topLeft, .bottomLeft])

                    VStack() {
                        Spacer()
						Image(systemName: self.placementImage)
							.resizable()
							.scaledToFit()
							.frame(width: 50)
                        Spacer()
						VStack(alignment: .leading) {
							Text("\(restaurantInfo.restaurant_name)")
                                .font(.title2)
                                .bold()
                            
							Text("Votes: \(restaurantInfo.rating)")
                                .font(.headline)
                                
                        }
                    
						Spacer()
					}
                    .padding()
				}
			}
			.frame(width: globalWidth, height: globalHeight, alignment: .center)
		}
	
	}
}

//struct ListCardView_Previews: PreviewProvider {
//	static var previews: some View {
//		ListCardView(restaurantInfo: FirebaseRestaurantInfo(name: "TEST", score: 10, url: "https://www.yelp.com/biz/gary-danko-san-francisco?adjust_creative=wpr6gw4FnptTrk1CeT8POg&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_lookup&utm_source=wpr6gw4FnptTrk1CeT8POg", image_url: "WavvLdfdP6g8aZTtbBQHTw"), placementImage: 1)
//	}
//}
