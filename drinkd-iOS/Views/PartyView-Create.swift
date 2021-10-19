//
//  PartyView-Create.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import SwiftUI

//@available(iOS 15.0, *)
struct PartyView_Create: View {
	@State private var partyName: String = ""
	@State private var winningVoteAmount: String = ""



	func formatStringtoInt(in textValue: String) -> Int {
		return Int(textValue) ?? 0
	}

	var body: some View {
		VStack {
			Text("Create Your Party")
				.font(.title)
			//
			TextField("Choose a Party Name(Max 8 Characters, No Numbers)", text: $partyName ) { isEditing in

			} onCommit: {

			}
			.border(Color(UIColor.separator))
			.textFieldStyle(.roundedBorder)
			//Removed Vote amount for now
//			TextField("Set You Vote Amount", text: $winningVoteAmount) { isEditing in
//
//			} onCommit: {
//
//			}
//			.border(Color(UIColor.separator))
//			.textFieldStyle(.roundedBorder)
//			.keyboardType(.numberPad)
			//
			CreatePartyButton(name: partyName, votes: winningVoteAmount)
			//
			Spacer()
		}
	}

	private struct CreatePartyButton: View {

		@EnvironmentObject var viewModel: drinkdViewModel
		@State private var showAlert: Bool = false

		var votes: String
		var name: String

		init(name: String, votes: String) {
			self.name = name
			self.votes = votes
		}

		var body: some View {

			Button("Create Party") {

				let filteredName = name.filter { "0123456789".contains($0) }
				let nameLength = name.count

				if ( nameLength > 8 || nameLength == 0 || filteredName.count > 0) {
					showAlert = true
					return
				} else {
					viewModel.createNewParty(setVotes: self.votes, setName: self.name)
					showAlert = false
				}

			}
			.alert(isPresented: $showAlert) {
				Alert(title: Text("Error"), message: Text("Check for Valid Name or Vote Amount"))
			}
			.buttonStyle(DefaultAppButton())
		}
	}

}






@available(iOS 15.0, *)
struct PartyView_Create_Previews: PreviewProvider {
	static var previews: some View {
		PartyView_Create()
	}
}
