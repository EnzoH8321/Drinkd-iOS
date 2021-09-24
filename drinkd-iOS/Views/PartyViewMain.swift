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
				Button("Join Party", action: {})
					.buttonStyle(JoinOrCreatePartyButton())
					.shadow(radius: AppShadow.lowShadowRadius)

				Button("Create Party", action: {})
					.buttonStyle(JoinOrCreatePartyButton())
					.shadow(radius: AppShadow.lowShadowRadius)
			}

		}
	}
}

struct PartyView_Previews: PreviewProvider {
	static var previews: some View {
		PartyView()
	}
}
