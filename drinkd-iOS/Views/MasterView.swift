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
    @Environment(LocationManager.self) var locationManager
	@State private var selectedTab: Int = 1

	var body: some View {

		VStack {
            if viewModel.removeSplashScreen {

                TabView(selection: $selectedTab) {
                    //
                    if (!locationManager.errorWithLocationAuth) {

                        HomeView()
                            .padding()
                            .padding(.bottom)
                            .tabItem {
                                Label("Home", systemImage: selectedTab == 1 ? "house.fill" : "house")
                                    .environment(\.symbolVariants, .none)
                            }.tag(1)


                    } else {
                        CustomLocationView()
                            .tabItem {
                                Image(systemName: "house")
                                Text("Home")
                            }.tag(1)
                    }
                    //
                    TopChoicesView()
                        .tabItem {
                            Label("TopChoices", systemImage: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                                .environment(\.symbolVariants, .none)
                        }.tag(2)
                    //
                    PartyView()
                        .tabItem {
                            Label("Party", systemImage: selectedTab == 3 ? "person.3.fill" : "person.3")
                                .environment(\.symbolVariants, .none)

                        }.tag(3)
                    //
                    SheetView()
                        .tabItem {
                            Label("Settings", systemImage: selectedTab == 4 ? "gearshape.fill" : "gearshape")
                                .environment(\.symbolVariants, .none)
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
