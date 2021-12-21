//
//  PartyCardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/14/21.
//

import SwiftUI

struct PartyCardView: View {

	@EnvironmentObject var viewModel: drinkdViewModel
	@State private var showingChatView = false

	var body: some View {
		GeometryReader { proxy in

			let globalWidth = proxy.frame(in: .global).width
			let globalHeight = proxy.frame(in: .global).height
			NavigationView {
				VStack {
					Spacer()
					ZStack {
						RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
							.fill(Color.white)
							.shadow(radius: AppShadow.lowShadowRadius)
							.frame(width: abs(globalWidth - 50), alignment: .center)

						VStack (alignment: .center) {
							Text("Party ID:")
								.font(.largeTitle)

							Text("\(viewModel.isPartyLeader ? viewModel.partyId : viewModel.friendPartyId)")
								.font(.title)

							Text("Partyname:")
								.font(.largeTitle)
							Text("\(viewModel.partyName)")
								.font(.title)

							Text("Votes to Win")
								.font(.largeTitle)
							Text("\(viewModel.partyMaxVotes)")
								.font(.title)

							NavigationLink(isActive: $showingChatView, destination: {ChatView()}, label: {EmptyView()})


							Button("Join Chat") {
								showingChatView = true
								viewModel.fetchExistingMessages()
								print(viewModel.chatMessageList)
							}
							.buttonStyle(viewModel.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))

							Button("Leave Party") {
								self.viewModel.leaveParty()
							}
							.buttonStyle(viewModel.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))
						}
					}
					.frame(width: globalWidth, height: globalHeight / 1.25)
					Spacer()
				}
			}.navigationBarHidden(true)


		}

	}
}

struct PartyCardView_Previews: PreviewProvider {
	static var previews: some View {
		PartyCardView()
			.environmentObject(drinkdViewModel())
	}
}
