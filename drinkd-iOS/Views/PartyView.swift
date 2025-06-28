//
//  PartyView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI


struct PartyView: View {

    @Environment(PartyViewModel.self) var viewModel

	var body: some View {
		NavigationView {
			if (!viewModel.currentlyInParty) {
				VStack {
                    Spacer()
					NavigationLink(destination: PartyView_Join()) {

                        Text("Join Party")
                            .bold()
					}
					.padding(.bottom, 55)
					.buttonStyle(Constants.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))

					NavigationLink(destination: PartyView_Create()) {

                        Text("Create Party")
                            .bold()
					}
					.buttonStyle(Constants.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))
                    Spacer()
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

struct PartyView_Previews: PreviewProvider {
	static var previews: some View {
		PartyView()
            .environment(PartyViewModel())

	}
}
