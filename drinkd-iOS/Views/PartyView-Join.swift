//
//  PartyView-Join.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import SwiftUI
import drinkdSharedModels

struct PartyView_Join: View {

    @Environment(PartyViewModel.self) var viewModel

    @State private var partyCode: String = ""
    @State private var personalUsername: String = ""
    @State private var showAlert: (state: Bool, message: String) = (false, "")

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack {
            Text("Join Party")
                .font(.title)
                .bold()
                .padding()

            // Create a Username
            VStack(alignment: .leading) {
                Text("Create a Username")
                    .font(.callout)
                    .bold()

                TextField("Enter a username here", text: $personalUsername)
                    .textFieldStyle(Styles.regularTextFieldStyle())
            }
            .padding()

            // Enter a Party ID
            VStack(alignment: .leading) {
                Text("Enter a Party Code")
                    .font(.callout)
                    .bold()

                TextField("Party Code", text: $partyCode)
                    .textFieldStyle(Styles.regularTextFieldStyle())
            }
            .padding()

            Button {

                Task {
                    do {
                        guard let partyCode = Int(partyCode) else { throw SharedErrors.general(error: .generalError("Unable to convert Party Code to an Integer"))}
                        try await Networking.shared.joinParty(viewModel: viewModel, partyCode: Int(partyCode), userName: personalUsername)
                    } catch {
                        Log.general.error("Error Joining Party - \(error)")
                        showAlert.state.toggle()
                        showAlert.message = error.localizedDescription
                    }

                }
            } label: {

                Text("Join Party")
                    .bold()

            }.alert(isPresented: $showAlert.state) {
                Alert(title: Text("Error"), message: Text(showAlert.message))
            }
            .buttonStyle(Styles.DefaultAppButton())

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

}

#Preview("In a Party") {
    let partyVM = PartyViewModel()
    let party = Party( username: "USER001" ,partyID: UUID(uuidString: "6f31b771-0027-4407-8c97-07a7609d3e2b")!, partyMaxVotes: 1, partyName: "Party Name", partyCode: 123123 ,yelpURL: "YELP API ")
    partyVM.currentParty = party

     return PartyView_Join()
        .environment(partyVM)
}

