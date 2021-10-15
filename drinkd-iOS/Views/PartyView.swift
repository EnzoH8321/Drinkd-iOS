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
					.buttonStyle(DefaultAppButton())

					NavigationLink(destination: PartyView_Create()) {
						JoinOrCreatePartyButton(buttonName: "Create Party")

					}
					.buttonStyle(DefaultAppButton())

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
					.buttonStyle(DefaultAppButton())
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
	}
}

@available(iOS 15.0, *)
struct PartyView_Previews: PreviewProvider {
	static var previews: some View {
		PartyView()
			.environmentObject(drinkdViewModel())

	}
}
