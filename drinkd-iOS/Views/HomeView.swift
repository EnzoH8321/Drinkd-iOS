//
//  HomeView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct HomeView: View {
	@EnvironmentObject var viewModel: drinkdViewModel

	

	var body: some View {
		GeometryReader{ proxy in
			ZStack {
				ForEach(0..<viewModel.restaurantList.count, id: \.self) { element in
					CardView(in: viewModel.restaurantList[element])
						.stacked(at: element, in: viewModel.restaurantList.count)
				}
			}
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
