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
			Text("You have disabled location services. Please provide custom coordinates for Drinkd to use by entering a latitude and longitude below. For a more streamlined experience, please enable location services.")
				.font(.title3)
            
            VStack(alignment: .leading) {
                Text("Please enter the latitude below")
                    .bold()
                    .padding(.top, 8)
                TextField("Latitude", text: $latitude)
                    .textFieldStyle(regularTextFieldStyle())
            }.padding()
			
            VStack(alignment: .leading) {
                Text("Please enter the longitude below")
                    .bold()
                    .padding(.top, 8)
                TextField("Longitude", text: $longitude)
                    .textFieldStyle(regularTextFieldStyle())
            }.padding()
            
			
			Button {
				//If 0.0 they are nil
				let latitude = Double(self.latitude) ?? 0.0
				let longitude = Double(self.longitude) ?? 0.0

				if (latitude == 0.0 || longitude == 0.0) {
					print("Values are wrong")
					return
				}
				fetchUsingCustomLocation(viewModel: viewModel,longitude: longitude, latitude: latitude) { result in

					switch(result) {
					case .success(_):
						print("Success")
					case .failure(_):
						print("Failure")
					}

				}
            } label: {
                Text("Submit")
                    .bold()
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
