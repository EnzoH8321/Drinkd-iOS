//
//  Star.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/6/21.
//

import SwiftUI
import drinkdSharedModels

struct Star: View {
    @Environment(PartyViewModel.self) var viewModel
    @Environment(Networking.self) var networking
    @Binding var showError: (status: Bool, message: String)
	@State private var hasBeenTapped = false
	@State private var rotationAmount = 0.0

	let starValue: Int
    let restaurantTitle: String
    let restaurantImageURL: String

    private var imageName: String {
        // If the resturant has already been rated, use that rating
        if let restaurant = viewModel.ratedRestaurants.first { $0.restaurant_name == restaurantTitle } {
            let rating = restaurant.rating

            return starValue > rating ? "star" : "star.fill"

        }

        return viewModel.currentScoreOfTopCard < 0 || starValue > viewModel.currentScoreOfTopCard ? "star" : "star.fill"
    }

    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .foregroundColor(AppColors.secondColor)
            .rotationEffect(.degrees(rotationAmount), anchor: .center)
            .onTapGesture {

                withAnimation(.default) {
                    if (hasBeenTapped) {
                        rotationAmount = 0.0
                        hasBeenTapped = false

                    } else {
                        rotationAmount = 360.0
                        hasBeenTapped = true
                    }
                }

                if starValue == 1 && viewModel.currentScoreOfTopCard == 1 {
                    viewModel.addScoreToCard(points: 0)
                } else {
                    viewModel.addScoreToCard(points: starValue)
                }

                guard let party = viewModel.currentParty else {
                    showError.message = "User is not in a party"
                    showError.status.toggle()
                    return
                }

                Task {
                    do {
                        let userID = try UserDefaultsWrapper.getUserID
                        try await networking.addRating(partyID: party.partyID, userID: userID, username: party.username, restaurantName: restaurantTitle, rating: viewModel.currentScoreOfTopCard, imageURL: restaurantImageURL)


                        // Update local rated restaurants list to reflect new rating
                        // Check if this restaurant has already been rated by finding existing entry
                        if let index = viewModel.ratedRestaurants.firstIndex { $0.restaurant_name == restaurantTitle} {
                            // Update existing rating with new score
                            viewModel.ratedRestaurants[index].rating = viewModel.currentScoreOfTopCard
                        } else {
                            // Create new rated restaurant entry since none exists
                            let newRatedRestaurant = RatedRestaurantsTable(
                                id: UUID(),
                                partyID: party.partyID,
                                userID: userID,
                                userName: party.username,
                                restaurantName: restaurantTitle,
                                rating: viewModel.currentScoreOfTopCard,
                                imageURL: restaurantImageURL
                            )
                            // Add new rating to local collection
                            viewModel.ratedRestaurants.append(newRatedRestaurant)
                        }



                    } catch {
                        // Handle any errors during rating submission or user ID retrieval
                        showError.message = error.localizedDescription
                        showError.status.toggle()
                    }

                }


            }

    }
}

#Preview {
    Star(showError: .constant((false, "")), starValue: 5, restaurantTitle: "TestRestaurant", restaurantImageURL: "ImageURL")
        .environment(PartyViewModel())
        .environment(Networking())
}
