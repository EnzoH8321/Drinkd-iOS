//
//  Star.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/6/21.
//

import SwiftUI

struct Star: View {
	@EnvironmentObject var viewModel: drinkdViewModel

	let starValue: Int



    var body: some View {
		Image(systemName: viewModel.currentScoreOfTopCard < 0 || starValue > viewModel.currentScoreOfTopCard ? "star" : "star.fill")
			.resizable()
			.onTapGesture {
					viewModel.addPoints(getPoints: starValue)
			}

    }
}

//struct Star_Previews: PreviewProvider {
//    static var previews: some View {
//		Star(score: <#Binding<Int>#>, hasBeenTapped: <#Bool#>)
//    }
//}
