//
//  PartyView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct PartyView: View {
	var body: some View {
		NavigationView {
			VStack {
				NavigationLink(destination: PartyView_Join()) {
					JoinOrCreatePartyButton(buttonName: "Join Party")

				}
				NavigationLink(destination: PartyView_Create()) {
					JoinOrCreatePartyButton(buttonName: "Create Party")
						
				}
			
			}
		}
	}
}


@available(iOS 15.0, *)
struct PartyView_Previews: PreviewProvider {
	static var previews: some View {
		PartyView()
	}
}
