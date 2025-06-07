//
//  PartyCardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/14/21.
//

import SwiftUI

struct PartyCardView: View {

    @Environment(PartyViewModel.self) var viewModel
	@State private var showingChatView = false
    @State private var showAlert: (state: Bool, message: String) = (false, "")

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

                            Text("\(viewModel.isPartyLeader ? viewModel.currentParty?.partyID : viewModel.friendPartyId)")
								.font(.title2)

							Text("Partyname:")
								.font(.largeTitle)
                            Text("\(viewModel.currentParty?.partyName)")
								.font(.title2)

							Text("Votes to Win")
								.font(.largeTitle)
                            Text("\(viewModel.currentParty?.partyMaxVotes)")
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
							.buttonStyle(Constants.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))
                            //
                            Button {
                                Task {
                                    do {
                                        try await Networking.shared.leaveParty()
                                        viewModel.leaveParty()
                                    } catch {
                                        showAlert = (true, error.localizedDescription)
                                    }

                                }


                            } label: {
								Text("Leave Party")
                                    .bold()
							}
							.buttonStyle(Constants.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))

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

struct PartyCardView_Previews: PreviewProvider {
	static var previews: some View {
		PartyCardView()			
	}
}
