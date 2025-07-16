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
    @State private var showingChatView = false
    @State private var showAlert: (state: Bool, message: String) = (false, "")

    private var partyID: String { viewModel.currentParty?.partyID ?? "" }
    private var friendPartyID: String { viewModel.friendPartyId ?? "" }
    private var partyName: String { viewModel.currentParty?.partyName ?? "" }
    private var partyVotes: Int { viewModel.currentParty?.partyMaxVotes ?? 0 }

    var body: some View {
        GeometryReader { proxy in

            let globalWidth = proxy.frame(in: .global).width

            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
                        .fill(Color.white)
                        .shadow(radius: AppShadow.lowShadowRadius)
                        .frame(width: abs(globalWidth - 50))

                    VStack {

                        Text("Party ID:")
                            .font(.largeTitle)

                        Text("\(viewModel.isPartyLeader ? partyID : friendPartyID)")
                            .font(.title2)

                        Text("Partyname:")
                            .font(.largeTitle)
                        Text("\(partyName)")
                            .font(.title2)

                        Text("Votes to Win")
                            .font(.largeTitle)
                        Text("\(partyVotes)")
                            .font(.title2)


                        NavigationLink(isActive: $showingChatView, destination: {ChatView()}, label: {EmptyView()})

                        Button {

                            Task {
                                guard let partyID = UserDefaultsWrapper.getPartyID() else {
                                    print("Unable to get Party ID")
                                    return
                                }
                                await Networking.shared.connectToWebsocket(partyVM: viewModel, username: viewModel.personalUserName, partyID: partyID)
                                showingChatView = true
                            }

                        } label: {
                            Text("Join Chat")
                                .bold()
                        }
                        .buttonStyle(Styles.DefaultAppButton())

                        //
                        Button {
                            Task {
                                do {
                                    guard let partyID = UserDefaultsWrapper.getPartyID() else { throw SharedErrors.general(error: .userDefaultsError("Unable to get the party ID"))}
                                    try await Networking.shared.leaveParty(partyVM: viewModel, partyID: partyID)
                                    viewModel.leaveParty()
                                } catch {
                                    showAlert = (true, error.localizedDescription)
                                }

                            }


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
            .alert(isPresented: $showAlert.state) {
                Alert(title: Text("Error"), message: Text(showAlert.message))
            }

        }

    }
}

//#Preview("Not in Party") {
//    PartyCardView()
//        .environment(PartyViewModel())
//}

#Preview("In a Party") {
    let partyVM = PartyViewModel()
    partyVM.currentlyInParty = true

     return PartyCardView()
        .environment(partyVM)
}

//struct PartyCardView_Previews: PreviewProvider {
//	static var previews: some View {
//		PartyCardView()			
//	}
//}
