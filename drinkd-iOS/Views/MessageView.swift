//
//  MessageView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/17/21.
//

import SwiftUI

struct MessageView: View {

	var username: String
	var message: String
	var personalChatID: Int
	var timestampString: String

	var body: some View {

			ZStack() {
				RoundedRectangle(cornerRadius: 5)
					.fill(Color(red: 203/255, green: 203/255, blue: 203/255))

				VStack(alignment: .leading, spacing: 10) {
					
					HStack {
						Text("\(username)")
							.bold()
							.padding([.leading, .top], 10)

						Text("\(timestampString)")
							.padding([.leading], 30)
					}
					
					Text("\(message)")
						.padding([.leading, .bottom], 10)
				}
			}


	}
}

struct MessageView_Previews: PreviewProvider {
	static var previews: some View {
		MessageView(username: "Enzo", message: "CHAT FEATURES WORKS", personalChatID: 4545454, timestampString: "Dfdfd")

	}
}
