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
        let testArray = [(key: "Mom\'s Kitchen & Bar", value: drinkd_iOS.FireBaseTopChoice(id: "xMUZfoyzyJoTfZxrEZus4Q", image_url: "https://s3-media3.fl.yelpcdn.com/bphoto/2em4dLRX21eieAsYXp_xUw/o.jpg", score: 8, url: "https://www.yelp.com/biz/moms-kitchen-and-bar-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "2988")), (key: "Hold Fast Kitchen & Spirits", value: drinkd_iOS.FireBaseTopChoice(id: "VLGmFHE4s0Sfu0piMVQa1Q", image_url: "https://s3-media4.fl.yelpcdn.com/bphoto/2a8BP3w4_pgEn8Y0E6TBow/o.jpg", score: 8, url: "https://www.yelp.com/biz/hold-fast-kitchen-and-spirits-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "2988")), (key: "Rudy\'s Bar & Grill", value: drinkd_iOS.FireBaseTopChoice(id: "4nohlTsGHEDdpwYkRTt-fA", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/k4saxN6f0AAXH1-aqNiSNQ/o.jpg", score: 5, url: "https://www.yelp.com/biz/rudys-bar-and-grill-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "2988")), (key: "Lilly\'s Craft and Kitchen", value: drinkd_iOS.FireBaseTopChoice(id: "JXcYD52B4190gIh6_RSXCg", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/M9xP4V9f8ZQe2TOtGVnNNg/o.jpg", score: 5, url: "https://www.yelp.com/biz/lillys-craft-and-kitchen-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "7827")), (key: "Ñaño Ecuadorian Kitchen", value: drinkd_iOS.FireBaseTopChoice(id: "9YXvNE2jpEhA4k6M8WDH7A", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/daSLaUvXCPKIRs1fUVL1Dg/o.jpg", score: 4, url: "https://www.yelp.com/biz/%C3%B1a%C3%B1o-ecuadorian-kitchen-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "2988")), (key: "Tanner Smiths", value: drinkd_iOS.FireBaseTopChoice(id: "z5hRX3iJ5Ty_S38iG_WY3Q", image_url: "https://s3-media3.fl.yelpcdn.com/bphoto/Cd4oaUWci9sYJbXy3fbqnw/o.jpg", score: 3, url: "https://www.yelp.com/biz/tanner-smiths-new-york-2?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "1185"))]
 
        mockViewModel.model.appendTopThreeRestaurants(in: testArray)
        
		return TopChoicesView()
			.environmentObject(mockViewModel)
	}
}
