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

	var body: some View {

		GeometryReader { proxy in

			let localWidth = proxy.frame(in: .local).width
			let localHeight = proxy.frame(in: .local).height

			ZStack {
				RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
					.fill(Color.white)
					.shadow(radius: AppShadow.lowShadowRadius)
				VStack {
					Image("testPicRestaurant")
						.resizable()
//						.scaledToFit()
						.frame(width: localWidth )
						.cornerRadius(radius: CardSpecificStyle.cornerRadius, corners: [.topLeft, .topRight])

					Text("Restaurant Name")

					Text("Number of Votes")
				}

			}
			.frame(width: localWidth, height: localHeight, alignment: .center)
		}
	}
}

struct ListCardView_Previews: PreviewProvider {
	static var previews: some View {
		ListCardView()
	}
}
