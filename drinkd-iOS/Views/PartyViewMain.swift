//
//  PartyView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct PartyView: View {
	var body: some View {
		VStack( spacing: 100) {
			Group{
				JoinOrCreatePartyButton(buttonName: "Join Party")
					
				JoinOrCreatePartyButton(buttonName: "Create Party")
			}


		}
	}
}

struct PartyView_Previews: PreviewProvider {
	static var previews: some View {
		PartyView()
	}
}
