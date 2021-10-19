//
//  PartyCardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/14/21.
//

import SwiftUI

struct PartyCardView: View {

	@EnvironmentObject var viewModel: drinkdViewModel

	var body: some View {
		GeometryReader { proxy in

			let globalWidth = proxy.frame(in: .global).width
			let globalHeight = proxy.frame(in: .global).height
			
			VStack {
				Spacer()
				ZStack {
					RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
						.fill(Color.white)
						.shadow(radius: AppShadow.lowShadowRadius)
						.frame(width: globalWidth - 50, alignment: .center)

					VStack (alignment: .leading) {
						Text("Party ID:")
							.font(.largeTitle)

						Text("\(viewModel.partyCreatorId ?? "Party ID not found")")
							.font(.title)

						Text("Partyname:")
							.font(.largeTitle)
						Text("\(viewModel.partyName ?? "Party Name not Found")")
							.font(.title)
						//Will implement in the future
//						Text("Votes to Win:")
//							.font(.largeTitle)
//						Text("\(viewModel.partyMaxVotes ?? "Party not found") ")
//							.font(.title)
						Button("Leave Party") {
							self.viewModel.leaveParty()
						}
						.buttonStyle(DefaultAppButton())
					}
				}
				.frame(width: globalWidth, height: globalHeight / 1.25)
				Spacer()
			}
		}

	}
}

struct PartyCardView_Previews: PreviewProvider {
	static var previews: some View {
		PartyCardView()
			.environmentObject(drinkdViewModel())
	}
}
