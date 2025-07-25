//
//  ContentView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI

struct MasterView: View {

    @Environment(PartyViewModel.self) var viewModel
	@State private var selectedTab: Int = 1

	var body: some View {

		VStack {
			if viewModel.removeSplashScreen {
				GeometryReader { proxy in

					let globalWidth = proxy.frame(in: .global).width
					let globalHeight = proxy.frame(in: .global).height

					TabView(selection: $selectedTab) {
						//
                        if (!Networking.shared.userDeniedLocationServices) {
							HomeView()
								.frame(width: globalWidth - 30 , height: globalHeight / 1.15)
								.padding(.bottom, 30)
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

				}
			} else {
				SplashScreen()
			}
		}
		
	}

}



@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
        MasterView()
            .environment(PartyViewModel())
	}
}
