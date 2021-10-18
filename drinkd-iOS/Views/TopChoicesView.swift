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
					ListCardView(restaurantInfo: self.viewModel.firstPlace, placementImage: 1)
						.frame(width: abs(globalWidth - 20))
						.frame(idealWidth: globalWidth - 20, maxHeight: globalHeight / 2)

					if (viewModel.currentlyInParty && viewModel.secondPlace.image_url != "") {
						ListCardView(restaurantInfo: self.viewModel.secondPlace, placementImage: 2)
							.frame(width: globalWidth - 20)
						if (viewModel.currentlyInParty && viewModel.thirdPlace.image_url != "") {

							ListCardView(restaurantInfo: self.viewModel.thirdPlace, placementImage: 3)
								.frame(width: globalWidth - 20)
								.padding([.bottom], 10)
						}
					}

				} else {
					Spacer()
					Text("There are currently no Top Choices!")
						.font(.largeTitle)
					Spacer()
				}
			}
			.frame(width: globalWidth)
		}
		//Sets image url for each card to an empty string. 
		.onDisappear(perform: {
			viewModel.removeImageUrl()
		})
	}

}

struct TopChoicesView_Previews: PreviewProvider {
	static var previews: some View {
		TopChoicesView()
			.environmentObject(drinkdViewModel())
	}
}
