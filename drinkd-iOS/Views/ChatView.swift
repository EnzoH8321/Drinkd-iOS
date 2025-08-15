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

        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack {
                        ForEach(viewModel.chatMessageList) { messageObj in
                            MessageView(username: messageObj.username, message: messageObj.text, messageUserID: messageObj.userID, timestamp: messageObj.timestamp)
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
                                // We copy messageString to a local var so we can safely reset messageString without having to wait for the async call to finish
                                let message = messageString
                                messageString.removeAll()
                                guard let party = viewModel.currentParty else { throw SharedErrors.general(error: .missingValue("Party value is nil"))}
                                try await networking.sendMessage(username: party.username, message: message, partyID: party.partyID)

                            } catch {
                                showAlert = (true, error.localizedDescription)
                            }
                        }

                    }, label: {
                        Image(systemName: "arrow.up.circle")
                            .font(.title)
                            .tint(AppColors.primaryColor)
                    })

                    Spacer()
                }
                .padding([.bottom])
            }
        }
        .alert(isPresented: $showAlert.state) {
            Alert(title: Text("Error"), message: Text(showAlert.message))
        }
    }
}

#Preview {

    do {
        let viewModel = PartyViewModel()
        // Supposed to be yourself
        let id1 = try UserDefaultsWrapper.getUserID
        let id2 = UUID()

        let chats: [WSMessage] = [
            WSMessage(id: UUID(), text: "Hi there, how are you?", username: "User001", timestamp: Date(), userID: id1),
            WSMessage(id: UUID(), text: "I'm good, just working right now!!!", username: "User002", timestamp: Date().advanced(by: 10), userID: id2),
            WSMessage(id: UUID(), text: "Busy Today?", username: "User001", timestamp: Date().advanced(by: 20), userID: id1),
            WSMessage(id: UUID(), text: "Yep, going to stay late I think!!!", username: "User002", timestamp: Date().advanced(by: 30), userID: id2),
        ]

        viewModel.chatMessageList = chats


       return ChatView()
            .environment(Networking())
            .environment(viewModel)
    } catch {
        return Text("Error: \(error)")
    }

}
