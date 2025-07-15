//
//  Star.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/6/21.
//

import SwiftUI

struct Star: View {
    @Environment(PartyViewModel.self) var viewModel
	@State private var hasBeenTapped = false
	@State private var rotationAmount = 0.0

	let starValue: Int

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


            }

    }
}

#Preview {
    Star(starValue: 4)
        .environment(PartyViewModel())
}
