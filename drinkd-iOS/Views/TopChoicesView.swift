//
//  TopChoicesView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI
import drinkdSharedModels

struct TopChoicesView: View {

    @Environment(PartyViewModel.self) var viewModel

    private var firstChoice: RatedRestaurantsTable? {
        return viewModel.topRestaurants[0]
    }

    private var secondChoice: RatedRestaurantsTable? {
        return viewModel.topRestaurants.indices.contains(1) ? viewModel.topRestaurants[1] : nil
    }

    private var thirdChoice: RatedRestaurantsTable? {
        return viewModel.topRestaurants.indices.contains(2) ? viewModel.topRestaurants[2] : nil
    }

	var body: some View {
		GeometryReader { proxy in

			let globalHeight = proxy.frame(in: .global).height
			let globalWidth = proxy.frame(in: .global).width

			VStack(alignment: .center) {

                if viewModel.currentlyInParty {

                    if !viewModel.topRestaurants.isEmpty {

                        if let firstChoice = firstChoice {
                            ListCardView(restaurantInfo: firstChoice, placementImage: 1)
                                .frame(width: abs(globalWidth - 20))
                                .frame(maxHeight: globalHeight / 3)
                        }

                        if let secondChoice = secondChoice {
                            ListCardView(restaurantInfo: secondChoice, placementImage: 2)
                                .frame(width: abs(globalWidth - 20))
                                .frame(maxHeight: globalHeight / 3)
                        }

                        if let thirdChoice = thirdChoice {

                            ListCardView(restaurantInfo: thirdChoice, placementImage: 3)
                                .frame(width: abs(globalWidth - 20))
                                .frame(maxHeight: globalHeight / 3)
                                .padding([.bottom], 10)
                        }

                    }
                    // If no restaurant has any votes
                    else {
                        Spacer()
                        Text("No one has voted for a restaurant yet!")
                            .font(.largeTitle)
                            .padding()
                        Spacer()
                    }


                }
                // If user is not in a party
                else {
                    Spacer()
                    Text("Please Join a Party to see the Top Choices!")
                        .font(.largeTitle)
                        .padding()
                    Spacer()
                }


			}
			.frame(width: globalWidth)
		}
        .task {
            do {
                guard let partyID = UserDefaultsWrapper.getPartyID() else {
                    Log.userDefaults.fault("Party ID not found in UserDefaults")
                    return
                }
                viewModel.topRestaurants = try await Networking.shared.getTopRestaurants(partyID: partyID).restaurants
                
            } catch {
                Log.general.fault("Error - \(error)")
            }
        }

	}

}

//struct TopChoicesView_Previews: PreviewProvider {
//	static var previews: some View {
//        
//        let mockViewModel = drinkdViewModel()
//        mockViewModel.model.setCurrentToPartyTrue()
//        let array1 = (key: "Ñaño Ecuadorian Kitchen", value: drinkd_iOS.FireBaseTopChoice(id: "9YXvNE2jpEhA4k6M8WDH7A", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/daSLaUvXCPKIRs1fUVL1Dg/o.jpg", score: 8, url: "https://www.yelp.com/biz/%C3%B1a%C3%B1o-ecuadorian-kitchen-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "16956"))
//        let array2 = (key: "Rudy\'s Bar & Grill", value: drinkd_iOS.FireBaseTopChoice(id: "4nohlTsGHEDdpwYkRTt-fA", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/k4saxN6f0AAXH1-aqNiSNQ/o.jpg", score: 5, url: "https://www.yelp.com/biz/rudys-bar-and-grill-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "4925"))
//        let array3 = (key: "Bea", value: drinkd_iOS.FireBaseTopChoice(id: "Rc1lxc5lSKJYd162JHNMfQ", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/m2d14AiiBqqly1gpMyU2RQ/o.jpg", score: 5, url: "https://www.yelp.com/biz/bea-new-york?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "19510"))
//        let testArray = [array1, array2, array3]
// 
//        mockViewModel.model.appendTopThreeRestaurants(in: testArray)
//        
//		return TopChoicesView()
//
//	}
//}
