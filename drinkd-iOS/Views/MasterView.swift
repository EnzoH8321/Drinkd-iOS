//
//  ContentView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI

struct MasterView: View {

	@ObservedObject	var viewModel: drinkdViewModel
	
	var body: some View {

		VStack {
			if viewModel.removeSplashScreen {
				GeometryReader { proxy in

					let globalWidth = proxy.frame(in: .global).width

					TabView {
						//HomeView
						NavigationView {
							HomeView(viewModel: self.viewModel)
								.frame(width: globalWidth - 30 , height: 650)
								.navigationBarTitle("")
								.navigationBarHidden(true)
						}
						.tabItem {
							Image(systemName: "house")
							Text("Home")
						}
						//Top Choices View
						NavigationView {
							TopChoicesView()
								.navigationBarTitle("")
								.navigationBarHidden(true)
						}
						.tabItem {
							Image(systemName: "chart.bar")
							Text("TopChoices")
						}
						//

						Text("PartyTab")
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
			self.viewModel.fetchLocalRestaurants()
		}

	}

}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MasterView(viewModel: drinkdViewModel())
	}
}
