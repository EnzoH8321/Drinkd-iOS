//
//  PartyView-Join.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import SwiftUI


struct PartyView_Join: View {

	@State private var partyCode: String = ""
	@State private var personalUsername: String = ""

	var body: some View {

		VStack {

			Text("Enter a Party ID Below")
				.font(.title)

			TextField("Enter a username here", text: $personalUsername)
				.textFieldStyle(regularTextFieldStyle())

			TextField("Party ID Here", text: $partyCode)
				.textFieldStyle(regularTextFieldStyle())

			JoinPartyButton(code: partyCode, username: personalUsername)

			Spacer()
		}
	}

	private struct JoinPartyButton: View {

		@EnvironmentObject var viewModel: drinkdViewModel

		var partyCode: String
		var username: String
		var personalUserID = Int.random(in: 1...4563456495)

		init(code: String, username: String) {
			self.partyCode = code
			self.username = username
		}

		var body: some View {

			Button("Join Party") {
				viewModel.JoinExistingParty(getCode: self.partyCode)
				viewModel.forModelSetUsernameAndId(username: self.username, id: self.personalUserID)
				fetchRestaurantsAfterJoiningParty(viewModel: viewModel) { result in
					switch(result) {
					case .success( _):
						print("Success")
					case .failure( _):
						print("Failure")
					}
				}
			}
			.alert(isPresented: $viewModel.queryPartyError) {
				Alert(title: Text("Error"), message: Text("Party Does not exist"))
			}
			.buttonStyle(viewModel.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))
		}
	}

}


@available(iOS 15.0, *)
struct PartyView_Join_Previews: PreviewProvider {
	static var previews: some View {
		PartyView_Join()
			.environmentObject(drinkdViewModel())
	}
}
