//
//  ListCardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI
import Foundation

struct ListCardView: View {

	var body: some View {

		GeometryReader { proxy in

			let localWidth = proxy.frame(in: .local).width
			let localHeight = proxy.frame(in: .local).height

			ZStack {
				HStack {
					Image("testPicRestaurant")
						.resizable()
						.scaledToFit()
						.frame(width: localWidth / 2)
					VStack(alignment: .leading ,spacing: 50) {
						Text("Restaurant Name")

						Text("Number of Votes")
					}
					.font(.title3)
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
