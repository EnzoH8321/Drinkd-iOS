//
//  PartyView-Create.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct PartyView_Create: View {
	@State var partyName: String = ""
	@State var winningVoteAmount: String = ""

	func formatStringtoInt(in textValue: String) -> Int {
		return Int(textValue) ?? 0
	}

	var body: some View {
		VStack {
			Text("Create Your Party")
				.font(.title)
			TextField("Party Name", text: $partyName, prompt: Text("Party Name Here"))
				.border(Color(UIColor.separator))
				.textFieldStyle(.roundedBorder)
			TextField("Set you vote amount", text: $winningVoteAmount) { isEditing in
				
			} onCommit: {

			}
			.border(Color(UIColor.separator))
			.textFieldStyle(.roundedBorder)
			JoinOrCreatePartyButton(buttonName: "Create Party")
		}
	}
}
@available(iOS 15.0, *)
struct PartyView_Create_Previews: PreviewProvider {
	static var previews: some View {
		PartyView_Create()
	}
}
