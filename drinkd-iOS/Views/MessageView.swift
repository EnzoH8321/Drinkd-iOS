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
		VStack(alignment: .leading) {
			
			HStack {
				Text("\(username)")
					.bold()

				Text("\(timestampString)")
					.padding([.leading], 30)
			}

			Text("\(message)")

		}
		

    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
		MessageView(username: "Enzo", message: "CHAT FEATURES WORKS", personalChatID: 4545454, timestampString: "Dfdfd")

    }
}
