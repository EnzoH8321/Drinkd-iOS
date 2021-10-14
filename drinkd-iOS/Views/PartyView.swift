//
//  PartyView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct PartyView: View {

	@EnvironmentObject var viewModel: drinkdViewModel

	var body: some View {
		NavigationView {
			if (!viewModel.currentlyInParty) {
				VStack {
					NavigationLink(destination: PartyView_Join()) {
						JoinOrCreatePartyButton(buttonName: "Join Party")
					}
					.padding(.bottom, 55)

					NavigationLink(destination: PartyView_Create()) {
						JoinOrCreatePartyButton(buttonName: "Create Party")
					}

				}
			} else {
				VStack{
					Text("Party ID: \(viewModel.partyCreatorId ?? "Party not found") ")
						.font(.title)
					Text("Partyname: \(viewModel.partyName ?? "Party Name not Found")")
						.font(.title)
					Text("Votes to Win: \(viewModel.partyMaxVotes ?? "Party not found") ")
						.font(.title)
					Button("Leave Party") {
						self.viewModel.leaveParty()
					}
					.padding(20)
					.frame(height: ButtonSyling.frameHeight)
					.padding()
					.background(AppColors.primaryColor)
					.clipShape(ButtonSyling.clipShape)
					.shadow(color: ButtonSyling.buttonShadowColor, radius: ButtonSyling.buttonShadowRadius, x: ButtonSyling.buttonShadowX, y: ButtonSyling.buttonShadowY)
					.padding(20)
				}
			}
		}
	}
}

//Used in the PartyView. Not a button to fit in with the navigation view requirements
@available(iOS 15.0, *)
struct JoinOrCreatePartyButton: View {

	let buttonName: String

	var body: some View {

		Text("\(buttonName)")
			.foregroundColor(ButtonSyling.buttonTextColor)
			.padding(20)
			.frame(height: ButtonSyling.frameHeight)
			.padding()
			.background(AppColors.primaryColor)
			.clipShape(ButtonSyling.clipShape)
			.shadow(color: ButtonSyling.buttonShadowColor, radius: ButtonSyling.buttonShadowRadius, x: ButtonSyling.buttonShadowX, y: ButtonSyling.buttonShadowY)
	}
}

@available(iOS 15.0, *)
struct PartyView_Previews: PreviewProvider {
	static var previews: some View {
		PartyView()
			.environmentObject(drinkdViewModel())

	}
}
