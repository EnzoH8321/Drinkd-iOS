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
				viewModel.JoinExistingParty(getCode: self.partyCode)
				viewModel.fetchRestaurantsAfterJoiningParty()
			}
			.alert(isPresented: $viewModel.queryPartyError) {
				Alert(title: Text("Error"), message: Text("Party Does not exists"))
			}
			.foregroundColor(ButtonSyling.buttonTextColor)
			.padding(20)
			.frame(height: ButtonSyling.frameHeight)
			.padding()
			.background(AppColors.primaryColor)
			.clipShape(ButtonSyling.clipShape)
			.shadow(color: ButtonSyling.buttonShadowColor, radius: ButtonSyling.buttonShadowRadius, x: ButtonSyling.buttonShadowX, y: ButtonSyling.buttonShadowY)
			.padding(20)

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
