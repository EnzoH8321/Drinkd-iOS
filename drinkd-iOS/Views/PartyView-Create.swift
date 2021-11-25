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
			TextField("Choose a Party Name(Max 15 Characters, No Numbers)", text: $partyName )
				.border(Color(UIColor.separator))
				.textFieldStyle(.roundedBorder)
			TextField("Set a Winning Vote Amount", text: $winningVoteAmount)
				.border(Color(UIColor.separator))
				.textFieldStyle(.roundedBorder)
			CreatePartyButton(name: partyName, votes: winningVoteAmount)
			//
			Spacer()
		}
	}

	private struct CreatePartyButton: View {

		@EnvironmentObject var viewModel: drinkdViewModel
		@State private var showAlert: Bool = false

		var votes: Int
		var name: String

		init(name: String, votes: String) {
			self.name = name
			self.votes = Int(votes) ?? 1
		}

		var body: some View {

			Button("Create Party") {

				let filteredName = name.filter { "0123456789".contains($0) }
				let nameLength = name.count

				if ( nameLength > 15 || nameLength == 0 || filteredName.count > 0) {
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
			.buttonStyle(viewModel.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))
		}
	}

}






@available(iOS 15.0, *)
struct PartyView_Create_Previews: PreviewProvider {
	static var previews: some View {
		PartyView_Create()
	}
}
