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
						//HomeView
						NavigationView {
							HomeView()
								.frame(width: globalWidth - 30 , height: globalHeight / 1.20)
								.navigationBarTitle("")
								.navigationBarHidden(true)
						}.navigationViewStyle(StackNavigationViewStyle())

						.tabItem {
							Image(systemName: "house")
							Text("Home")
						}.tag(1)

						//Top Choices View
						NavigationView {
							TopChoicesView()
								.navigationBarTitle("")
								.navigationBarHidden(true)
						}.navigationViewStyle(StackNavigationViewStyle())
						.tabItem {
							Image(systemName: "chart.bar")
							Text("TopChoices")
						}.tag(2)
						//Party View
						NavigationView {
							PartyView()
								.frame(width: globalWidth, height: globalHeight)
								.navigationBarTitle("")
								.navigationBarHidden(true)
						}.navigationViewStyle(StackNavigationViewStyle())
						.tabItem {
							Image(systemName: "person.3")
							Text("Party")
						}.tag(3)
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
		.onAppear {
			self.viewModel.fetchRestaurantsOnStartUp()
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
