//
//  ChatView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/17/21.
//

import SwiftUI

struct ChatView: View {

	@EnvironmentObject var viewModel: drinkdViewModel
	@State var messageString = ""

    var body: some View {
		VStack{
			List {
				ForEach(viewModel.chatMessageList) { message in
					MessageView(username: message.username, message: message.message, personalChatID: message.personalId, timestamp: message.timestamp)
				}
			}
			HStack {
				TextField("Text Here", text: $messageString)
					.border(Color(UIColor.separator))
					.textFieldStyle(.roundedBorder)
				Button(action: {
					let stringifiedUUID = UUID().uuidString
					let timeStamp = Date().currentTimeMillis()
					let message = FireBaseMessage(id: stringifiedUUID, username: viewModel.personalUsername, personalId: viewModel.personalID, message: messageString, timestamp: timeStamp)
					viewModel.sendMessage(forMessage: message)
				}, label: {
					Image(systemName: "arrow.right")
				})
			}
		}
	}

}

struct ChatView_Previews: PreviewProvider {

	let test = ""

    static var previews: some View {
        ChatView()
			.environmentObject(drinkdViewModel())
    }
}
