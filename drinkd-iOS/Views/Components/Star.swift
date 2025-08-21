//
//  Star.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/6/21.
//

import SwiftUI

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
//                        if viewModel.currentScoreOfTopCard == 0 { return }
                        try await networking.addRating(partyID: party.partyID, userID: userID, username: party.username, restaurantName: restaurantTitle, rating: viewModel.currentScoreOfTopCard, imageURL: restaurantImageURL)
                    } catch {
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
