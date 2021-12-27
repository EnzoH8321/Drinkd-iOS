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
					.fill(Color(red: 230/255, green: 230/255, blue: 230/255))

				VStack(alignment: .leading, spacing: 10) {
					
                    HStack(alignment: .bottom) {
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
            .cornerRadius(8)
            .padding([.leading, .trailing], 10)

	}
}

struct MessageView_Previews: PreviewProvider {
	static var previews: some View {
		MessageView(username: "Enzo", message: "CHAT FEATURES WORKS", personalChatID: 4545454, timestampString: "Dfdfd")

	}
}

