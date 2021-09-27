//
//  Button.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct YelpDetailButton: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.background(AppColors.primaryColor)
			.clipShape(Capsule())
	}
}

//Used in the PartyViewMain
struct JoinOrCreatePartyButton: View {

	let buttonName: String

	var body: some View {
		Button {
			print("Button pressed")
		} label: {
			Text("\(buttonName)")
				.padding(20)
		}
		.frame(height: 20)
		.padding()
		.background(AppColors.primaryColor)
		.clipShape(Capsule())
	}
}



struct Button_Previews: PreviewProvider {
	static var previews: some View {
		JoinOrCreatePartyButton(buttonName: "Join Party")
	}
}
