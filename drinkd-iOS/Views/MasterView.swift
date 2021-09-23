//
//  ContentView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationView {
			TabView {
				//Put View in place of text
				Text("HomeTab")
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
			.font(.headline)
//			.toolbar {
//				Image("drinkd_text")
//					.resizable()
//					.scaledToFit()
//			}

        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		ContentView()
    }
}
