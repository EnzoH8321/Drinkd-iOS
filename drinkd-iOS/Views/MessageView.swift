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
		GeometryReader { geo in

			let fullWidth = geo.frame(in: .global).width
			let fullHeight = geo.frame(in: .global).height

			ZStack() {
				RoundedRectangle(cornerRadius: 5)
					.fill(Color(red: 203/255, green: 203/255, blue: 203/255))

				VStack(alignment: .leading, spacing: 10) {
					
					HStack {
						Text("\(username)")
							.bold()

						Text("\(timestampString)")
							.padding([.leading], 30)
					}
					
					Text("\(message)")
				}
			}
			.frame(width: fullWidth)
		}
	}
}

struct MessageView_Previews: PreviewProvider {
	static var previews: some View {
		MessageView(username: "Enzo", message: "CHAT FEATURES WORKS", personalChatID: 4545454, timestampString: "Dfdfd")

	}
}
