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
			ZStack{
				VStack {
					Text("RestaurantTitle")
						.font(.largeTitle)
					Text("Restaurant Detail")
						.font(.title2)
					Text("Score / Money")
						.font(.title3)
					Image("drinkd_text")
						.resizable()
						.scaledToFit()
						.frame(width: geo.frame(in: .global).width)
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
			}
		}

	}
}

struct CardView_Previews: PreviewProvider {
	static var previews: some View {
		CardView()
	}
}
