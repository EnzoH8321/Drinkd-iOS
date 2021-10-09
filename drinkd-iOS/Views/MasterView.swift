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

	//Firebase
	var ref = Database.database().reference()
	
	var body: some View {

		VStack {
			if viewModel.removeSplashScreen {
				GeometryReader { proxy in

					let globalWidth = proxy.frame(in: .global).width
					let globalHeight = proxy.frame(in: .global).height

					TabView {
						//HomeView
						NavigationView {
							HomeView()
								.frame(width: globalWidth - 30 , height: globalHeight / 1.15)
								.navigationBarTitle("")
								.navigationBarHidden(true)
						}.navigationViewStyle(StackNavigationViewStyle())
						.tabItem {
							Image(systemName: "house")
							Text("Home")
						}
						//Top Choices View
						NavigationView {
							TopChoicesView()
								.navigationBarTitle("")
								.navigationBarHidden(true)
						}.navigationViewStyle(StackNavigationViewStyle())
						.tabItem {
							Image(systemName: "chart.bar")
							Text("TopChoices")
						}
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
