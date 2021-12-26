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

		GeometryReader { geo in

			let globalWidth = geo.frame(in: .global).width
			let globalHeight = geo.frame(in: .global).height

			VStack {
				ScrollView {
					VStack {
						ForEach(viewModel.chatMessageList) { messageObj in
							MessageView(username: messageObj.username, message: messageObj.message, personalChatID: messageObj.personalId, timestampString: messageObj.timestampString)
								.frame(height: globalHeight * 0.10)
						}
					}
				}

				HStack {
					TextField("Enter Text Here", text: $messageString)
						.textFieldStyle(regularTextFieldStyle())
						.frame(width: globalWidth * 0.75)
					
					Button(action: {

						let stringifiedUUID = UUID().uuidString
						let timeStamp = Date().currentTimeMillis()
						let message = FireBaseMessage(id: stringifiedUUID, username: viewModel.personalUsername, personalId: viewModel.personalID, message: messageString, timestamp: timeStamp, timestampString: Date().formatDate(forMilliseconds: timeStamp))

						sendMessage(forMessage: message, viewModel: viewModel)

					}, label: {
						Image(systemName: "arrowtriangle.right.fill")
							.resizable()
							.frame(width: 25, height: 25)
					})
						.padding([.leading], 20)
				}
				.padding([.bottom], 10)
			}
		}
	}
}

struct ChatView_Previews: PreviewProvider {

	let test = ""

	static var previews: some View {
		let drinkd = drinkdViewModel()
		drinkd.model.fetchEntireMessageList(messageList: [FireBaseMessage(id: "34234", username: "Enzo", personalId: 34, message: "Hello Man, how are you doing? This is enzo. I am currently in LA. Why La you may as? well this is something", timestamp: 34, timestampString: "3434"), FireBaseMessage(id: "34234", username: "Enzo", personalId: 34, message: "Hello Man, how are you doing? This is enzo. I am currently in Alabama", timestamp: 34, timestampString: "3434")])
		return ChatView()
			.environmentObject(drinkd)
	}
}
