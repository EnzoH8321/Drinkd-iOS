//
//  ContentView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI
import Firebase

@available(iOS 15.0, *)
struct MasterView: View {

	@EnvironmentObject var viewModel: drinkdViewModel
	@State private var selectedTab: Int = 1
	//Firebase
	var ref = Database.database().reference()
	
	var body: some View {

		VStack {
			if viewModel.removeSplashScreen {
				GeometryReader { proxy in

					let globalWidth = proxy.frame(in: .global).width
					let globalHeight = proxy.frame(in: .global).height

					TabView(selection: $selectedTab) {
							//
							if (!viewModel.userLocationError) {
								HomeView()
									.frame(width: globalWidth - 30 , height: globalHeight / 1.15)
									.padding(.bottom, 30)
									.navigationBarTitle("")
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
								.frame(width: globalWidth, height: globalHeight)
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
					.onChange(of: selectedTab) {tabVal in
						switch (tabVal) {
						case 2 :
							viewModel.calculateTopThreeRestaurants()
							
						default:
							break
						}
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
			.environmentObject(drinkdViewModel())
	}
}
