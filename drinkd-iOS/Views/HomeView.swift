//
//  HomeView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct HomeView: View {
    @Environment(PartyViewModel.self) var viewModel
    // Used to manually refresh view
    @State var refreshView = false
    @State var cardCounter = 9

    var body: some View {

        ZStack {
            ForEach(0..<viewModel.localRestaurants.count, id: \.self) { element in
                CardView(cardCounter: $cardCounter, in: viewModel.localRestaurants[element])
                    .stacked(at: element, in: viewModel.localRestaurants.count)
            }
        }
        .id(refreshView)
        .onChange(of: cardCounter) { oldValue, newValue in
            if newValue == 0 {
                // Used to Manually refresh view
                refreshView.toggle()
            }
        }

    }

}

//For stacked styling
extension View {
	func stacked(at position: Int, in total: Int) -> some View {
		let offset = CGFloat(total - position)

		return self.offset(CGSize(width: 0, height: offset * -2))
	}
}

#Preview("In a Party") {
    let partyVM = PartyViewModel()
    let party = Party(username: "USERNAME01" ,partyID: UUID(uuidString: "6f31b771-0027-4407-8c97-07a7609d3e2b")!, partyMaxVotes: 1, partyName: "Party Name", partyCode: 123123 ,yelpURL: "YELP API ")
    partyVM.currentParty = party

    let searchProp1 = YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 5, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "$$", location: YelpApiBusinessDetails_Location(address1: "155 W 51st St", address2: "Suite 1-", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "650-339-0869", display_phone: "test", distance: 6565.56)

    let searchProp2 = YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 5, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "$$", location: YelpApiBusinessDetails_Location(address1: "155 W 51st St", address2: "Suite 1-", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "650-339-0869", display_phone: "test", distance: 6565.56)

    let searchProp3 = YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 5, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "$$", location: YelpApiBusinessDetails_Location(address1: "155 W 51st St", address2: "Suite 1-", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "650-339-0869", display_phone: "test", distance: 6565.56)


    partyVM.localRestaurants.append(contentsOf: [searchProp1, searchProp2, searchProp3])

    return HomeView()
        .environment(partyVM)
        .environment(Networking())
}
