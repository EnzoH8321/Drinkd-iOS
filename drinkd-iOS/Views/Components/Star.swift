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

	var body: some View {
		Image(systemName: viewModel.currentScoreOfTopCard < 0 || starValue > viewModel.currentScoreOfTopCard ? "star" : "star.fill")
			.resizable()
			.foregroundColor(AppColors.secondColor)
			.rotationEffect(.degrees(rotationAmount), anchor: .center)
			.animation(.default)
			.onTapGesture {

				if (hasBeenTapped) {
					rotationAmount = 0.0
					hasBeenTapped = false

				} else {
				 rotationAmount = 360.0
				 hasBeenTapped = true
				}

				viewModel.addScoreToCard(points: starValue)
			}

	}
}

struct Star_Previews: PreviewProvider {
	static var previews: some View {
		Star(starValue: 5)			
	}
}
