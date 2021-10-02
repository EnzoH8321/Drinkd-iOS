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
			Spacer()
		}


	}
}


@available(iOS 15.0, *)
struct PartyView_Join_Previews: PreviewProvider {
	static var previews: some View {
		PartyView_Join()
	}
}
