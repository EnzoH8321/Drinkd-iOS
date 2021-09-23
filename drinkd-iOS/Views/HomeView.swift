//
//  HomeView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct HomeView: View {
	var body: some View {
		GeometryReader{ proxy in



			CardView()
//				.frame(width: globalWidth - 30 , height: 400)
			//Lessens the vertical space that nav view automatically takes
				.navigationBarTitle("")
				.navigationBarHidden(true)
		}

	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
	}
}
