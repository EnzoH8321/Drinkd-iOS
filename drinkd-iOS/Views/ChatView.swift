//
//  ChatView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/17/21.
//

import SwiftUI
import drinkdSharedModels

struct ChatView: View {
    @Environment(Networking.self) var networking
    @Environment(PartyViewModel.self) var viewModel
	@State var messageString = ""
    @State private var showAlert: (state: Bool, message: String) = (false, "")

	var body: some View {

		GeometryReader { geo in
			
			VStack {
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack {
                            ForEach(viewModel.chatMessageList) { messageObj in
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
                                    guard let party = viewModel.currentParty else { throw SharedErrors.general(error: .missingValue("Party value is nil"))}
                                    try await networking.sendMessage(username: party.username, message: messageString, partyID: party.partyID)
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
