//
//  ListCardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI
import Foundation
import drinkdSharedModels

struct ListCardView: View {

	let restaurantInfo: RatedRestaurantsTable
	let placementImage: String

	init(restaurantInfo: RatedRestaurantsTable, placementImage: Int) {
		self.restaurantInfo = restaurantInfo

		switch (placementImage) {
		case 1:
			self.placementImage = "1.circle"
		case 2:
			self.placementImage = "2.circle"
		case 3:
			self.placementImage = "3.circle"
		default:
			self.placementImage = "xmark.octagon"
		}
		
	}

    private var image: Image {
        guard let imageData = restaurantInfo.imageData,  let uiImage = UIImage(data: imageData) else {
            return Image(systemName: "multiply.circle")
        }

       return Image(uiImage: uiImage)
    }

	var body: some View {

		GeometryReader { proxy in

			let globalWidth = proxy.frame(in: .global).width
			let globalHeight = proxy.frame(in: .global).height

			ZStack {
				RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
					.fill(Color.white)
					.shadow(radius: AppShadow.lowShadowRadius)

				HStack {

                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: globalWidth * 0.50, height: globalHeight)
                        .clipShape(UnevenRoundedRectangle(
                            topLeadingRadius: CardSpecificStyle.cornerRadius,
                            bottomLeadingRadius: CardSpecificStyle.cornerRadius
                        ))

                    Spacer()

                    VStack {

						Image(systemName: self.placementImage)
							.resizable()
                            .aspectRatio(contentMode: .fit)
							.frame(width: 50)

						VStack(alignment: .leading) {
							Text("\(restaurantInfo.restaurant_name)")
                                .font(.title2)
                                .bold()
                            
							Text("Votes: \(restaurantInfo.rating)")
                                .font(.headline)
                                
                        }
                    
						Spacer()
					}
                    .padding()
                    .frame(width: globalWidth * 0.50)

				}
			}
			.frame(width: globalWidth, height: globalHeight, alignment: .center)
		}
	
	}
}


#Preview {
    let ratedRestaurant = RatedRestaurantsTable(id: UUID(), partyID: UUID(), userID: UUID(), userName: "TestUsername", restaurantName: "Pabu Izakaya", rating: 5, imageURL: "https://www.yelp.com/biz/gary-danko-san-francisco?adjust_creative=wpr6gw4FnptTrk1CeT8POg&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_lookup&utm_source=wpr6gw4FnptTrk1CeT8POg")

    let ratedRestaurant2 = RatedRestaurantsTable(id: UUID(), partyID: UUID(), userID: UUID(), userName: "TestUsername", restaurantName: "Sotto Mare", rating: 5, imageURL: "https://www.yelp.com/biz/gary-danko-san-francisco?adjust_creative=wpr6gw4FnptTrk1CeT8POg&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_lookup&utm_source=wpr6gw4FnptTrk1CeT8POg")

    VStack {
        ListCardView(restaurantInfo: ratedRestaurant, placementImage: 1)
        ListCardView(restaurantInfo: ratedRestaurant2, placementImage: 2)
        ListCardView(restaurantInfo: ratedRestaurant, placementImage: 3)
    }
    .padding()

}
