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
			if (!viewModel.showPartyDetailScreen) {
				VStack {
					NavigationLink(destination: PartyView_Join()) {
						JoinOrCreatePartyButton(buttonName: "Join Party")
					}

					NavigationLink(destination: PartyView_Create()) {
						JoinOrCreatePartyButton(buttonName: "Create Party")
					}

				}
			} else {
				Text("Party ID: \(viewModel.partyMaxVotes ?? "Party not found") ")
					.font(.title)
				Text("Partyname: \(viewModel.partyName ?? "Party Name not Found")")
					.font(.title)
				Text("Votes to Win: \(viewModel.partyMaxVotes ?? "Party not found") ")
					.font(.title)
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
