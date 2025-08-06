//
//  PartyCardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/14/21.
//

import SwiftUI
import drinkdSharedModels

struct PartyCardView: View {

    @Environment(PartyViewModel.self) var viewModel
    @State private var showAlert: (state: Bool, message: String) = (false, "")
    @State private var path = NavigationPath()

    private var partyCode: String {
        guard let code = viewModel.currentParty?.partyCode else { return "" }
        return "\(code)"
    }
    private var partyName: String { viewModel.currentParty?.partyName ?? "" }
    private var partyVotes: Int { viewModel.currentParty?.partyMaxVotes ?? 0 }
    private var userName: String { viewModel.currentParty?.username ?? ""}

    private func joinChat()  {
        path.append("chat")
    }

    private func leaveParty() {

        Task {
            do {
                guard let partyID = viewModel.currentParty?.partyID else { throw SharedErrors.general(error: .userDefaultsError("Unable to get the party ID"))}
                try await Networking.shared.leaveParty(partyVM: viewModel, partyID: partyID)
                viewModel.leaveParty()
            } catch {
                // Leave the Party Anyway in case of failure
                viewModel.leaveParty()
                showAlert = (true, error.localizedDescription)
            }

        }
    }

    var body: some View {
        GeometryReader { proxy in

            let globalWidth = proxy.frame(in: .global).width
            NavigationStack(path: $path) {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
                            .fill(Color.white)
                            .shadow(radius: AppShadow.lowShadowRadius)
                            .frame(width: abs(globalWidth - 50))

                        VStack {

                            Text("Partyname:")
                                .font(.largeTitle)
                            Text("\(partyName)")
                                .font(.title2)

                            Text("Username")
                                .font(.largeTitle)
                            Text("\(userName)")
                                .font(.title2)

                            Text("Party Code:")
                                .font(.largeTitle)
                            Text(partyCode)
                                .font(.title2)

                            Text("Votes to Win")
                                .font(.largeTitle)
                            Text("\(partyVotes)")
                                .font(.title2)

                            Button {
                                joinChat()
                            } label: {
                                Text("Join Chat")
                                    .bold()
                            }
                            .buttonStyle(Styles.DefaultAppButton())

                            //
                            Button {
                                leaveParty()
                            } label: {
                                Text("Leave Party")
                                    .bold()
                            }
                            .buttonStyle(Styles.DefaultAppButton())

                        }
                    }
                    .frame(width: globalWidth)
                    Spacer()
                }
                .navigationDestination(for: String.self) { value in
                        if value == "chat" {
                            ChatView()
                        }
                    }
                .alert(isPresented: $showAlert.state) {
                    Alert(title: Text("Error"), message: Text(showAlert.message))
                }
            }

        }

    }
}

#Preview("In a Party") {
    let partyVM = PartyViewModel()
    let party = Party( username: "USER001" ,partyID: UUID(uuidString: "6f31b771-0027-4407-8c97-07a7609d3e2b")!, partyMaxVotes: 1, partyName: "Party Name", partyCode: 123123 ,yelpURL: "YELP API ")
    partyVM.currentParty = party

     return PartyCardView()
        .environment(partyVM)
}

