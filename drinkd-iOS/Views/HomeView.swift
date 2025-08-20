//
//  HomeView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct HomeView: View {
    @Environment(PartyViewModel.self) var viewModel

    var visibleCardsCount: Int = 2
    // View properties
    @State private var rotation: Int = 0

    var body: some View {

        Group(subviews: baseView()) { collection in
            let modifiedCollection = collection.rotateFromLeft(by: rotation)
            let count = modifiedCollection.count

            ZStack {
                ForEach(modifiedCollection) { view in
                    // lets reverse the stack with zindex
                    let index = modifiedCollection.index(view)
                    let zIndex = Double(count - index)

                    StackableWrapper(index: index, count: count, visibleCardsCount: visibleCardsCount, rotation: $rotation) {
                        view
                    }
                    .zIndex(zIndex)

                }
            }
        }
    }

}

extension HomeView {
    @ViewBuilder func baseView() -> some View {
        ForEach(0..<viewModel.localRestaurants.count, id: \.self) { element in
            CardView(in: viewModel.localRestaurants[element])
        }
    }
}


#Preview("In a Party") {
    let partyVM = PartyViewModel()
    let party = Party(username: "USERNAME01" ,partyID: UUID(uuidString: "6f31b771-0027-4407-8c97-07a7609d3e2b")!, partyMaxVotes: 1, partyName: "Party Name", partyCode: 123123 ,yelpURL: "YELP API ")
    partyVM.currentParty = party

    let searchProp1 = YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds1", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 5, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "$$", location: YelpApiBusinessDetails_Location(address1: "155 W 51st St", address2: "Suite 1-", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "650-339-0869", display_phone: "test", distance: 6565.56)

    let searchProp2 = YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds2", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 5, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "$$", location: YelpApiBusinessDetails_Location(address1: "155 W 51st St", address2: "Suite 1-", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "650-339-0869", display_phone: "test", distance: 6565.56)

    let searchProp3 = YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds3", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 5, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "$$", location: YelpApiBusinessDetails_Location(address1: "155 W 51st St", address2: "Suite 1-", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "650-339-0869", display_phone: "test", distance: 6565.56)


    partyVM.localRestaurants.append(contentsOf: [
        searchProp1,
        searchProp2,
        searchProp3,
        searchProp1,
        searchProp2,
        searchProp3,
        searchProp1,
        searchProp2,
        searchProp3
    ]
    )

    return HomeView()
        .environment(partyVM)
        .environment(Networking())
}
