//
//  ChatView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/17/21.
//

import SwiftUI

struct ChatView: View {

	@EnvironmentObject var viewModel: drinkdViewModel

    var body: some View {
		List {
			ForEach(viewModel.chatMessageList) { message in
				MessageView(username: message.username, message: message.message, personalChatID: message.personalChatId)
			}

		}
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
