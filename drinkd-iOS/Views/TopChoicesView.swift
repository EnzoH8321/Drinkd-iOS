//
//  TopChoicesView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct TopChoicesView: View {

	@EnvironmentObject var viewModel: drinkdViewModel

	var body: some View {
		GeometryReader { proxy in

			let globalHeight = proxy.frame(in: .global).height
			let globalWidth = proxy.frame(in: .global).width

			VStack(alignment: .center) {

				if (viewModel.currentlyInParty && viewModel.firstPlace.image_url != "") {
					ListCardView(restaurantInfo: self.viewModel.firstPlace)
						.frame(width: abs(globalWidth - 20), height: globalHeight / 3.5)
					Spacer()
					ListCardView(restaurantInfo: self.viewModel.secondPlace)
						.frame(width: globalWidth - 20, height: globalHeight / 3.5)
					Spacer()
					ListCardView(restaurantInfo: self.viewModel.thirdPlace)
						.frame(width: globalWidth - 20, height: globalHeight / 3.5)
						.padding([.bottom], 10)
				} else {
					Text("Join or Create your own party to see your top choices")
						.font(.largeTitle)
				}

			}
			.frame(width: globalWidth, height: globalHeight)
		}


	}

}

struct TopChoicesView_Previews: PreviewProvider {
	static var previews: some View {
		TopChoicesView()
			.environmentObject(drinkdViewModel())
	}
}
