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
	@State private var userName: String = ""

	func formatStringtoInt(in textValue: String) -> Int {
		return Int(textValue) ?? 0
	}

	var body: some View {
		VStack {
			Text("Create Your Party")
				.font(.title)
			//
			TextField("Choose a Username", text: $userName)
				.border(Color(UIColor.separator))
				.textFieldStyle(.roundedBorder)
			TextField("Choose a Party Name(Max 15 Characters, No Numbers)", text: $partyName )
				.border(Color(UIColor.separator))
				.textFieldStyle(.roundedBorder)
			TextField("Set a Winning Vote Amount", text: $winningVoteAmount)
				.border(Color(UIColor.separator))
				.textFieldStyle(.roundedBorder)
			CreatePartyButton(partyName: partyName, votes: winningVoteAmount, userName: userName)
			//
			Spacer()
		}
	}

	private struct CreatePartyButton: View {

		@EnvironmentObject var viewModel: drinkdViewModel
		@State private var showAlert: Bool = false

		var votes: Int
		var partyName: String
		var userName: String
		var personalUserID = Int.random(in: 1...4563456495)

		init(partyName: String, votes: String, userName: String) {
			self.partyName = partyName
			self.votes = Int(votes) ?? 1
			self.userName = userName
		}

		var body: some View {

			Button("Create Party") {

				let filteredPartyName = partyName.filter { "0123456789".contains($0) }

				let nameLength = partyName.count

				if ( nameLength > 15 || nameLength == 0 || filteredPartyName.count > 0 || userName.count > 20) {
					showAlert = true
					return
				} else {
					viewModel.createNewParty(setVotes: self.votes, setName: self.partyName)
					viewModel.forModelSetUsernameAndId(username: self.userName, id: self.personalUserID)
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
			.environmentObject(drinkdViewModel())
	}
}
