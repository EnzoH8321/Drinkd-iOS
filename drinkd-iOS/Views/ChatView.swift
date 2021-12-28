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

			let globalWidth = geo.frame(in: .local).width
			
			VStack {
				ScrollView {
					VStack {
						ForEach(viewModel.chatMessageList, id: \.self) { messageObj in
                            MessageView(username: messageObj.username, message: messageObj.message, messageChatID: messageObj.personalId, personalChatId: viewModel.personalID ,timestampString: messageObj.timestampString)
								
						}
					}
				}

				HStack {
                    Spacer()
					TextField("Enter Text Here", text: $messageString)
						.textFieldStyle(regularTextFieldStyle())
						.frame(width: globalWidth * 0.75)
					
					Button(action: {

						let stringifiedUUID = UUID().uuidString
						let timeStamp = Date().currentTimeMillis()
						let message = FireBaseMessage(id: stringifiedUUID, username: viewModel.personalUsername, personalId: viewModel.personalID, message: messageString, timestamp: timeStamp, timestampString: Date().formatDate(forMilliseconds: timeStamp))

						sendMessage(forMessage: message, viewModel: viewModel)

					}, label: {
						Image(systemName: "plus")
							.resizable()
//                            .foregroundColor(AppColors.primaryColor)
							.frame(width: 20, height: 20)
					})
						.padding([.leading], 20)
                    Spacer()
				}
				.padding([.bottom], 10)
			}
		}
	}
}

struct ChatView_Previews: PreviewProvider {

	static var previews: some View {
        let drinkd = drinkdViewModel()
		drinkd.model.fetchEntireMessageList(messageList: [FireBaseMessage(id: "34234", username: "Enzo", personalId: 35, message: "Hello Man, how are you doing? This is enzo. I am currently in LA. Why La you may as? well this is something", timestamp: 34, timestampString: "3434"), FireBaseMessage(id: "34234", username: "Enzo", personalId: 36, message: "Hello Man, how are you doing? This is enzo. I am currently in Alabama", timestamp: 34, timestampString: "3434")])
        drinkd.model.setPersonalUserAndID(forName: "Enzo", forID: 35)
		return ChatView()
			.environmentObject(drinkd)
	}
}
