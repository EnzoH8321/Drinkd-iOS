//
//  PartyView-Create.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import SwiftUI
import drinkdSharedModels

//@available(iOS 15.0, *)
struct PartyView_Create: View {
    @State private var partyName: String = ""
    @State private var winningVoteAmount: String = ""
    @State private var userName: String = ""
    @State private var showAlert: (state: Bool, message: String) = (false, "")
    @Environment(PartyViewModel.self) var partyVM

    var body: some View {
        @Bindable var partyVM = partyVM
        VStack {
            Text("Create Your Party")
                .font(.title)
                .bold()
                .padding()
            //
            VStack(alignment: .leading, spacing: 1) {
                Text("Create a Username")
                    .font(.callout)
                    .bold()
                    .padding([.bottom], 8)
                
                TextField("Username", text: $userName)
                    .textFieldStyle(Styles.regularTextFieldStyle())
            }.padding()
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Create a Party Name")
                    .font(.callout)
                    .bold()
                    .padding([.bottom], 8)
                
                TextField("Party Name(Max 15 Characters, No Numbers)", text: $partyName )
                    .textFieldStyle(Styles.regularTextFieldStyle())
            }.padding()
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Set a Winning Vote Amount")
                    .font(.callout)
                    .bold()
                    .padding([.bottom], 8)
                
                TextField("Votes", text: $winningVoteAmount)
                    .textFieldStyle(Styles.regularTextFieldStyle())
            }.padding()
            
            Button {

                let filteredPartyName = partyName.filter { "0123456789".contains($0) }
                let partyNameLength = partyName.count

                if ( partyNameLength > 15 || partyNameLength == 0 || filteredPartyName.count > 0 || userName.count > 20) {
                    showAlert = (true, "Incorrect name length or party name")
                    return
                }

                Task {
                    do {
                        let urlString = try Networking.shared.createYelpBusinessURLString()
                        let response = try await Networking.shared.createParty(username: userName, partyName: partyName ,restaurantsURL: urlString)
                        partyVM.setPersonalUserAndID(forName: response.currentUserName, forID: response.currentUserID)

                    } catch {
                        Log.networking.fault("Error - \(error)")
                        showAlert = (true, error.localizedDescription)
                    }
                }

            } label: {
                Text("Create Party")
                    .bold()
            }
            .alert(isPresented: $showAlert.state) {
                Alert(title: Text("Error"), message: Text(showAlert.message))
            }
            .buttonStyle(Styles.DefaultAppButton())
            //
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}






@available(iOS 15.0, *)
struct PartyView_Create_Previews: PreviewProvider {
    static var previews: some View {
        PartyView_Create()
            .environment(PartyViewModel())
    }
}
