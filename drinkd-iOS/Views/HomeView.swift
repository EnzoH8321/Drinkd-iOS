//
//  HomeView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct HomeView: View {

	@EnvironmentObject var viewModel: drinkdViewModel

	var body: some View {
		GeometryReader{ proxy in
			ForEach(viewModel.restaurantList, id: \.self) { element in
				CardView(in: element)
			}
		}

	}
}

struct HomeView_Previews: PreviewProvider {
	static let myEnvObject = drinkdViewModel()

	static var previews: some View {
		HomeView().environmentObject(myEnvObject)
	}
}
