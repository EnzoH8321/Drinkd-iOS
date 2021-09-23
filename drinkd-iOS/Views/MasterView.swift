//
//  ContentView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI

struct ContentView: View {

	var body: some View {
		GeometryReader { proxy in

			let globalWidth = proxy.frame(in: .global).width

			TabView {
				NavigationView {
					//Put View in place of text
					CardView()
						.frame(width: globalWidth - 30 ,height: 400)
					//Lessens the vertical space that nav view automatically takes
						.navigationBarTitle("")
						.navigationBarHidden(true)
				}
				.tabItem {
					Image(systemName: "house")
					Text("Home")
				}

				Text("TopChoicesTab")
					.tabItem {
						Image(systemName: "chart.bar")
						Text("TopChoices")
					}

				Text("PartyTab")
					.tabItem {
						Image(systemName: "person.3")
						Text("Party")
					}

			}
		}


	}

}




struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		ContentView()
	}
}
