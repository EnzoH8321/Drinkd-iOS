//
//  PartyView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI


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
					.buttonStyle(viewModel.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))

					NavigationLink(destination: PartyView_Create()) {
						JoinOrCreatePartyButton(buttonName: "Create Party")
					}
					.buttonStyle(viewModel.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))

				}
			} else {
				VStack{
					PartyCardView()
				}
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())

	}
}

//Used in the PartyView. Not a button to fit in with the navigation view requirements
struct JoinOrCreatePartyButton: View {

	let buttonName: String

	var body: some View {
		Text("\(buttonName)")
	}
}




struct PartyView_Previews: PreviewProvider {
	static var previews: some View {
		PartyView()
			.environmentObject(drinkdViewModel())

	}
}
