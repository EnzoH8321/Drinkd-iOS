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
						.frame(maxHeight: globalHeight / 2)

					if (viewModel.currentlyInParty && viewModel.secondPlace.image_url != "") {
						ListCardView(restaurantInfo: self.viewModel.secondPlace, placementImage: 2)
							.frame(width: abs(globalWidth - 20))
						if (viewModel.currentlyInParty && viewModel.thirdPlace.image_url != "") {

							ListCardView(restaurantInfo: self.viewModel.thirdPlace, placementImage: 3)
								.frame(width: abs(globalWidth - 20))
								.padding([.bottom], 10)
						}
					}

				} else {
					Spacer()
					Text("Please Join a Party to see the Top Choices!")
						.font(.largeTitle)
                        .padding()
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
        
        let mockViewModel = drinkdViewModel()
        mockViewModel.model.setCurrentToPartyTrue()
        let testArray = [(key: "Lilly\'s Craft and Kitchen", value: drinkd_iOS.FireBaseTopChoice(id: "JXcYD52B4190gIh6_RSXCg", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/M9xP4V9f8ZQe2TOtGVnNNg/o.jpg", score: 2, url: "https://www.yelp.com/biz/lillys-craft-and-kitchen-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "7827")), (key: "Lilly\'s Craft and Kitchen", value: drinkd_iOS.FireBaseTopChoice(id: "JXcYD52B4190gIh6_RSXCg", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/M9xP4V9f8ZQe2TOtGVnNNg/o.jpg", score: 2, url: "https://www.yelp.com/biz/lillys-craft-and-kitchen-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "7827")), (key: "Lilly\'s Craft and Kitchen", value: drinkd_iOS.FireBaseTopChoice(id: "JXcYD52B4190gIh6_RSXCg", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/M9xP4V9f8ZQe2TOtGVnNNg/o.jpg", score: 2, url: "https://www.yelp.com/biz/lillys-craft-and-kitchen-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "7827"))]
 
        mockViewModel.model.appendTopThreeRestaurants(in: testArray)
        
		return TopChoicesView()
			.environmentObject(mockViewModel)
	}
}
