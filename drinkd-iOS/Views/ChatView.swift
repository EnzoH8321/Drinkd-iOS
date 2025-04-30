//
//  ChatView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/17/21.
//

import SwiftUI
//TODO: Make Chat dynamic, update on the fly.
struct ChatView: View {

    @Environment(drinkdViewModel.self) var viewModel
	@State var messageString = ""

	var body: some View {

		GeometryReader { geo in

//			let globalWidth = geo.frame(in: .local).width
			
			VStack {
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack {
                            ForEach(viewModel.chatMessageList, id: \.self) { messageObj in
                                MessageView(username: messageObj.username, message: messageObj.message, messageChatID: messageObj.personalId, personalChatId: viewModel.personalUserID ,timestampString: messageObj.timestampString)

                            }
                        }
                    }

                    HStack {
                        Spacer()
                        TextField("Enter Text Here", text: $messageString)
                            .textFieldStyle(regularTextFieldStyle())
//                            .frame(width: globalWidth * 0.75)
//                            .padding(.leading, 8)
                        
                        Button(action: {

                            let stringifiedUUID = UUID().uuidString
                            let timeStamp = Date().currentTimeMillis()
                            let message = FireBaseMessage(id: stringifiedUUID, username: viewModel.personalUserName, personalId: viewModel.personalUserID, message: messageString, timestamp: timeStamp, timestampString: Date().formatDate(forMilliseconds: timeStamp))

                            Networking.shared.sendMessage(forMessage: message, viewModel: viewModel)
                            //Scrolls to the last message after hitting the button if not empty
                            if (!viewModel.chatMessageList.isEmpty) {
                                scrollView.scrollTo(viewModel.chatMessageList[viewModel.chatMessageList.endIndex - 1])
                            }
                            
                        }, label: {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 20, height: 20)
                        })
                            .padding([.leading, .trailing], 8)
                        Spacer()
                    }
                    .padding([.bottom], 16)
                    
                }
				
			}
            .onDisappear {
                //Removes the FB messaging observer
                Networking.shared.removeMessagingObserver(viewModel: viewModel)
            }
		}
    }
}

struct ChatView_Previews: PreviewProvider {

	static var previews: some View {
        let drinkd = drinkdViewModel()
		drinkd.chatMessageList = [FireBaseMessage(id: "34234", username: "Enzo", personalId: 35, message: "Hello Man, how are you doing? This is enzo. I am currently in LA. Why La you may as? well this is something", timestamp: 34, timestampString: "3434"), FireBaseMessage(id: "34234", username: "Enzo", personalId: 36, message: "Hello Man, how are you doing? This is enzo. I am currently in Alabama", timestamp: 34, timestampString: "3434")]
        drinkd.setPersonalUserAndID(forName: "Enzo", forID: 35)
		return ChatView()
			.environment(drinkd)
	}
}
