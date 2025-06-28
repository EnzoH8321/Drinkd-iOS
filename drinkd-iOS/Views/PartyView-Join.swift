//
//  PartyView-Join.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import SwiftUI


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
            VStack(alignment: .leading, spacing: 1) {
                Text("Create a Username")
                    .font(.callout)
                    .bold()
                    .padding([.bottom], 8)

                TextField("Enter a username here", text: $personalUsername)
                    .textFieldStyle(regularTextFieldStyle())
            }
            .padding()
            // Enter a Party ID
            VStack(alignment: .leading, spacing: 1) {
                Text("Enter a Party ID")
                    .font(.callout)
                    .bold()
                    .padding([.bottom], 8)
                TextField("Party ID", text: $partyCode)
                    .textFieldStyle(regularTextFieldStyle())
            }
            .padding()

            Button {
                fetchRestaurantsAfterJoiningParty()
            } label: {

                Text("Join Party")
                    .bold()

            }.alert(isPresented: $showAlert.state) {
                Alert(title: Text("Error"), message: Text(showAlert.message))
            }
            .buttonStyle(Constants.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func fetchRestaurantsAfterJoiningParty() {
        Networking.shared.fetchRestaurantsAfterJoiningParty(viewModel: viewModel) { result in

            switch(result) {
            case .success( _):
                print("Success")
            case .failure( let error):
                showAlert.state.toggle()
                showAlert.message = error.localizedDescription
            }

        }
    }

}


@available(iOS 15.0, *)
struct PartyView_Join_Previews: PreviewProvider {
    static var previews: some View {
        PartyView_Join()
    }
}
