//
//  ContentView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var viewModel = drinkdViewModel()
	@State var isActive: Bool = false

	var body: some View {

		VStack {
			if isActive {
				GeometryReader { proxy in

					let globalWidth = proxy.frame(in: .global).width

					TabView {
						//HomeView
						NavigationView {
							HomeView()
								.frame(width: globalWidth - 30 , height: 500)
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
//			self.viewModel.fetchNearbyPlaces()
		}
	}

}




struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		ContentView()
	}
}
