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

    var body: some View {
		VStack(alignment: .leading) {
			Text("\(username)")
			Text("\(message)")
			
		}
		.border(.black, width: 1)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(username: "Enzo", message: "CHAT FEAUTRES WORKS", personalChatID: 4545454)
    }
}
