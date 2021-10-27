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
			Text("To provide a custom location, please enter a latitude and longitude below.")
				.font(.title3)
			Text("Latitude")
			TextField("Latitude", text: $latitude)
				.border(Color(UIColor.separator))
				.textFieldStyle(.roundedBorder)

			Text("Longitude")
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
