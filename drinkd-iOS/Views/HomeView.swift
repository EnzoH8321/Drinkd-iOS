//
//  HomeView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct HomeView: View {
	@EnvironmentObject var viewModel: drinkdViewModel

	//	@State var currentScore = 0

	var body: some View {
		GeometryReader{ proxy in

			let globalHeight = proxy.frame(in: .global).height

			VStack {
				ZStack {
					ForEach(0..<viewModel.restaurantList.count, id: \.self) { element in
						CardView(in: viewModel.restaurantList[element], forView: self.viewModel)
							.stacked(at: element, in: viewModel.restaurantList.count)
					}

				}

				if (viewModel.currentlyInParty) {
					Spacer()
					HStack {
						Group {
							Star( starValue: 1)
							Star( starValue: 2)
							Star( starValue: 3)
							Star( starValue: 4)
							Star( starValue: 5)
						}
						.scaledToFit()
						.frame(height: 50)
						.padding([.top], globalHeight / 25)
					}
					SubmitButton()
						.onTapGesture {
							viewModel.sendFBRestaurantScores()
						}
				}

			}
		}

	}

	private struct SubmitButton: View {
		
		var body: some View {
			Text("Submit")
				.padding(20)
				.frame(height: 20)
				.padding()
				.background(AppColors.primaryColor)
				.clipShape(Capsule())
		}
	}

}

struct HomeView_Previews: PreviewProvider {
	static let myEnvObject = drinkdViewModel()

	static var previews: some View {
		HomeView()
			.environmentObject(drinkdViewModel())
	}
}

//For stacked styling
extension View {
	func stacked(at position: Int, in total: Int) -> some View {
		let offset = CGFloat(total - position)
		return self.offset(CGSize(width: 0, height: offset * 2))
	}
}
