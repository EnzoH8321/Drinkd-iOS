//
//  HomeView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct HomeView: View {
	@EnvironmentObject var viewModel: drinkdViewModel
    @State var refreshView = false

	var body: some View {
		GeometryReader{ proxy in

			VStack {
                ZStack {
                    //TODO: Find a way to refresh without having to toggle between card views.

                    ForEach(0..<viewModel.restaurantList.count, id: \.self) { element in
                        CardView(in: viewModel.restaurantList[element], forView: self.viewModel)
                            .stacked(at: element, in: viewModel.restaurantList.count)

                    }

                }
                .id(refreshView)
			}
            .onChange(of: viewModel.model.counter) { oldValue, newValue in
                if newValue == 0 {
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


struct HomeView_Previews: PreviewProvider {
	static let myEnvObject = drinkdViewModel()

	static var previews: some View {
		HomeView()
			.environmentObject(drinkdViewModel())
	}
}

