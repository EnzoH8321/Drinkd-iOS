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
		GeometryReader{ proxy in

			VStack {
                ZStack {
                    //TODO: Find a way to refresh without having to toggle between card views.

                    ForEach(0..<viewModel.localRestaurants.count, id: \.self) { element in
                        CardView(cardCounter: $cardCounter, in: viewModel.localRestaurants[element])
                            .stacked(at: element, in: viewModel.localRestaurants.count)

                    }

                }
                .id(refreshView)
			}
            .onChange(of: cardCounter) { oldValue, newValue in
                if newValue == 0 {
                    // Used to Manually refresh view
                    refreshView.toggle()
                }
            }
		}

	}
		

}

//For stacked styling
extension View {
	func stacked(at position: Int, in total: Int) -> some View {
		let offset = CGFloat(total - position)

		return self.offset(CGSize(width: 0, height: offset * 2))
	}
}


//struct HomeView_Previews: PreviewProvider {
//	static let myEnvObject = PartyViewModel()
//
//	static var previews: some View {
//		HomeView()
//	}
//}

#Preview("In a Party") {
    let partyVM = PartyViewModel()
    let party = Party(username: "USERNAME01" ,partyID: UUID(uuidString: "6f31b771-0027-4407-8c97-07a7609d3e2b")!, partyMaxVotes: 1, partyName: "Party Name", partyCode: 123123 ,yelpURL: "YELP API ")
    partyVM.currentParty = party

    return HomeView()
        .environment(partyVM)
}
