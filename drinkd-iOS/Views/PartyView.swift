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
					.frame(height: 20)
					.padding()
					.background(AppColors.primaryColor)
					.clipShape(Capsule())
				}
			}
		}
	}
}


@available(iOS 15.0, *)
struct PartyView_Previews: PreviewProvider {
	static var previews: some View {
		PartyView()
			.environmentObject(drinkdViewModel())

	}
}
