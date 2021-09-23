//
//  CardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI

struct CardView: View {
	var body: some View {

		GeometryReader{ geo in
			ZStack {
				let globalWidth = geo.frame(in: .global).width

				Rectangle()
					.fill(Color.white)

					.shadow(color: Color.black, radius: 3.0, x: 5.0, y: 5.0)

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
						.frame(width: globalWidth)
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
					Button(action: {}) {
						Text("Sign In")
					}
					.background(Color.purple)
				}
				//For Vstack
//				.zIndex(1.0)
			}

			
		}

	}
}

struct CardView_Previews: PreviewProvider {
	static var previews: some View {
		CardView()
	}
}
