//
//  Star.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/6/21.
//

import SwiftUI

struct Star: View {
	@EnvironmentObject var viewModel: drinkdViewModel
	@State var hasBeenTapped = false
	@State var score = 0
	let starValue: Int
	

    var body: some View {
		Image(systemName: "star")
			.resizable()
			.onTapGesture {
				self.hasBeenTapped.toggle()

				if (hasBeenTapped) {
					score += starValue
					viewModel.addPoints(getPoints: score)
				} else {
					score = 0
					viewModel.minusPoints()
				}
			}
    }
}

//struct Star_Previews: PreviewProvider {
//    static var previews: some View {
//		Star(score: <#Binding<Int>#>, hasBeenTapped: <#Bool#>)
//    }
//}
