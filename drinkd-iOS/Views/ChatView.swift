//
//  ChatView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/17/21.
//

import SwiftUI
import drinkdSharedModels

struct ChatView: View {

    @Environment(PartyViewModel.self) var viewModel
	@State var messageString = ""
    @State private var showAlert: (state: Bool, message: String) = (false, "")

	var body: some View {

		GeometryReader { geo in
			
			VStack {
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack {
                            ForEach(viewModel.chatMessageList, id: \.self) { messageObj in
                                MessageView(username: messageObj.username, message: messageObj.text, messageUserID: messageObj.userID, timestampString: "\(messageObj.timestamp)")
                            }
                        }
                    }

                    HStack {
                        Spacer()
                        TextField("Enter Text Here", text: $messageString)
                            .textFieldStyle(Styles.regularTextFieldStyle())
                        
                        Button(action: {

                            Task {
                                do {
                                    guard let partyID = UserDefaultsWrapper.getPartyID() else { throw SharedErrors.general(error: .missingValue("Unable to get party id"))}
                                    try await Networking.shared.sendMessage(message: messageString, partyID: partyID)
                                } catch {
                                   showAlert = (true, error.localizedDescription)
                                }
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
            .alert(isPresented: $showAlert.state) {
                Alert(title: Text("Error"), message: Text(showAlert.message))
            }
		}
    }
}

//struct ChatView_Previews: PreviewProvider {
//
//	static var previews: some View {
//        let drinkd = PartyViewModel()
//        drinkd.chatVM.chatMessageList = [FireBaseMessage(id: "34234", username: "Enzo", personalId: 35, message: "Hello Man, how are you doing? This is enzo. I am currently in LA. Why La you may as? well this is something", timestamp: 34, timestampString: "3434"), FireBaseMessage(id: "34234", username: "Enzo", personalId: 36, message: "Hello Man, how are you doing? This is enzo. I am currently in Alabama", timestamp: 34, timestampString: "3434")]
//        drinkd.chatVM.setPersonalUserAndID(forName: "Enzo", forID: UUID())
//		return ChatView()
//			.environment(drinkd)
//	}
//}
