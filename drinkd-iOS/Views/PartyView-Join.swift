//
//  PartyView-Join.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct PartyView_Join: View {

	@State var partyCode: String = ""

	var body: some View {

		VStack {
			Text("Enter a Party Code Below")
				.font(.title)
			TextField("Party Code", text: $partyCode, prompt: Text("Party Code Here"))
				.border(Color(UIColor.separator))
				.textFieldStyle(.roundedBorder)
			
			JoinPartyButton(code: partyCode)

			Spacer()
		}
	}

	private struct JoinPartyButton: View {
		@EnvironmentObject var viewModel: drinkdViewModel

		var partyCode: String

		init(code: String) {
			self.partyCode = code
		}

		var body: some View {

			Button("Join Party") {
				
				viewModel.getParty(getCode: self.partyCode)
				viewModel.fetchRestaurantsAfterJoiningParty()

			}
			.alert(isPresented: $viewModel.queryPartyError) {
				Alert(title: Text("Error"), message: Text("Party Does not exists"))
			}
			.padding(20)
			.frame(height: 20)
			.padding()
			.background(AppColors.primaryColor)
			.clipShape(Capsule())
		}
	}

}


@available(iOS 15.0, *)
struct PartyView_Join_Previews: PreviewProvider {
	static var previews: some View {
		PartyView_Join()
	}
}
