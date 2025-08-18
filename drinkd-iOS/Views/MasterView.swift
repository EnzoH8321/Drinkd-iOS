//
//  ContentView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI

struct MasterView: View {
    @Environment(Networking.self) var networking
    @Environment(PartyViewModel.self) var viewModel
	@State private var selectedTab: Int = 1

	var body: some View {

		VStack {
			if viewModel.removeSplashScreen {

					TabView(selection: $selectedTab) {
						//
                        if (!networking.userDeniedLocationServices) {

                            ZStack {

                                AppColors.primaryColor
                                    .ignoresSafeArea(.all, edges: .top)

                                HomeView()
                                    .padding()
                                    .padding(.bottom)

                            }
                            .navigationTitle("")
                            .navigationBarHidden(true)
                            .tabItem {
                                Image(systemName: "house")
                                Text("Home")
                            }.tag(1)


						} else {
							CustomLocationView()
								.navigationBarTitle("")
								.navigationBarHidden(true)
								.tabItem {
									Image(systemName: "house")
									Text("Home")
								}.tag(1)
						}
						//
						TopChoicesView()
							.navigationBarTitle("")
							.navigationBarHidden(true)
							.tabItem {
								Image(systemName: "chart.bar")
								Text("TopChoices")
							}.tag(2)
						//
						PartyView()
							.navigationBarTitle("")
							.navigationBarHidden(true)
							.tabItem {
								Image(systemName: "person.3")
								Text("Party")
							}.tag(3)
						//
						SheetView()
							.tabItem {
								Image(systemName: "list.bullet")
								Text("Settings")
							}.tag(4)

					}

			} else {
				SplashScreen()
			}
		}
		
	}

}

#Preview {
    let partyVM = PartyViewModel()
    let party = Party(username: "USERNAME01" ,partyID: UUID(uuidString: "6f31b771-0027-4407-8c97-07a7609d3e2b")!, partyMaxVotes: 1, partyName: "Party Name", partyCode: 123123 ,yelpURL: "YELP API ")
    partyVM.currentParty = party

   return MasterView()
        .environment(partyVM)
        .environment(Networking())
}
