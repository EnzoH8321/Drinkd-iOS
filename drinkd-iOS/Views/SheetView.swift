//
//  SheetView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 11/12/21.
//

import SwiftUI

struct SheetView: View {
	var body: some View {
		NavigationView {
			List {
				NavigationLink(destination: HowToView()) {
					Text("How To")
				}

			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct SheetView_Previews: PreviewProvider {
	static var previews: some View {
		SheetView()
	}
}
