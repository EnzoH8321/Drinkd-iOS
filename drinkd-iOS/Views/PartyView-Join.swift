//
//  PartyView-Join.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import SwiftUI


struct PartyView_Join: View {
    
    @State private var partyCode: String = ""
    @State private var personalUsername: String = ""
    
    var body: some View {
        VStack {
            Text("Join Party")
                .font(.title)
                .padding()
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Create a Username")
                    .font(.callout)
                    .padding([.bottom], 8)
               
                TextField("Enter a username here", text: $personalUsername)
                    .textFieldStyle(regularTextFieldStyle())
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Enter a Party ID")
                    .font(.callout)
                    .padding([.bottom], 8)
                TextField("Party ID", text: $partyCode)
                    .textFieldStyle(regularTextFieldStyle())
            }
            .padding()
            
            JoinPartyButton(code: partyCode, username: personalUsername)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
        
    
    private struct JoinPartyButton: View {
        
        @EnvironmentObject var viewModel: drinkdViewModel
        
        var partyCode: String
        var username: String
        var personalUserID = Int.random(in: 1...4563456495)
        
        init(code: String, username: String) {
            self.partyCode = code
            self.username = username
        }
        
        var body: some View {
            
            Button {
                
                viewModel.JoinExistingParty(getCode: self.partyCode)
                viewModel.forModelSetUsernameAndId(username: self.username, id: self.personalUserID)
                fetchRestaurantsAfterJoiningParty(viewModel: viewModel) { result in
                    
                    switch(result) {
                    case .success( _):
                        print("Success")
                    case .failure( _):
                        print("Failure")
                    }
                    
                }
            } label: {
                
                Text("Join Party")
                    .bold()
                
            }.alert(isPresented: $viewModel.queryPartyError) {
                Alert(title: Text("Error"), message: Text("Party Does not exist"))
            }
            .buttonStyle(viewModel.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))
        }
    }
    
}


@available(iOS 15.0, *)
struct PartyView_Join_Previews: PreviewProvider {
    static var previews: some View {
        PartyView_Join()
            .environmentObject(drinkdViewModel())
    }
}
