//
//  CardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

//245,31,32

import SwiftUI

enum CardPadding: CGFloat{
	case smallPadding = 4
}

struct CardView: View {

	var body: some View {

		GeometryReader { geo in
			ZStack {
				let localWidth = geo.frame(in: .local).width

				RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
					.fill(Color.white)
					.shadow(radius: AppShadow.lowShadowRadius)

				VStack(alignment: .leading) {
					Text("RestaurantTitle")
						.font(.largeTitle)
					Text("Restaurant Detail")
						.font(.title2)
					Text("Score / Money")
						.font(.title3)
					Image("drinkd_text")
						.resizable()
						.scaledToFit()
						.frame(width: localWidth - 30)
					Group {
						HStack {
							Image(systemName: "house")
								.resizable()
								.scaledToFit()
								.frame(width: 40)
							Text("Address")
						}
						HStack {
							Image(systemName: "phone")
								.resizable()
								.scaledToFit()
								.frame(width: 40)
							Text("Phone number")
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
