//
//  CustomLocationView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/26/21.
//

import SwiftUI

struct CustomLocationView: View {

	@EnvironmentObject var viewModel: drinkdViewModel

	@State var latitude: String = ""
	@State var longitude: String = ""

	var body: some View {
		VStack {
			Text("You have disabled tracking services. Please provide custom coordinates for Drinkd to use by entering a latitude and longitude below. For a more streamlined experience, please enable location services.")
				.font(.title3)
			Text("Please enter the Latitude below")
				.padding(.top, 10)
			TextField("Latitude", text: $latitude)
				.border(Color(UIColor.separator))
				.textFieldStyle(.roundedBorder)

			Text("Please enter the Longitude below")
			TextField("Longitude", text: $longitude)
				.border(Color(UIColor.separator))
				.textFieldStyle(.roundedBorder)

			Button("Submit Custom Location") {
				//If 0.0 they are nil
				let latitude = Double(self.latitude) ?? 0.0
				let longitude = Double(self.longitude) ?? 0.0

				if (latitude == 0.0 || longitude == 0.0) {
					print("values are wrong")
					return
				}
				viewModel.fetchUsingCustomLocation(longitude: longitude, latitude: latitude)
			}
			.buttonStyle(viewModel.isPhone ? DefaultAppButton(deviceType: .phone) : DefaultAppButton(deviceType: .ipad))
			Spacer()
		}
	}
}

struct CustomLocationView_Previews: PreviewProvider {
	static var previews: some View {
		CustomLocationView()
			.environmentObject(drinkdViewModel())
	}
}
