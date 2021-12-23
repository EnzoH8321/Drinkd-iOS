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
	var timestamp: Int

    var body: some View {
		VStack(alignment: .leading) {
			Text("\(username)")
				.bold()
			Text("\(message)")
			Text("\(timestamp)")
		}

    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
		MessageView(username: "Enzo", message: "CHAT FEAUTRES WORKS", personalChatID: 4545454, timestamp: 345346346456546)
    }
}
