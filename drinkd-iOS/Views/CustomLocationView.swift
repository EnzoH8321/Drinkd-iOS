//
//  CustomLocationView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/26/21.
//

import SwiftUI

struct CustomLocationView: View {

    @Environment(PartyViewModel.self) var viewModel

	@State private var latitude: String = ""
	@State private var longitude: String = ""
    @State private var showAlert: (message: String, state: Bool) = ("", false)

	var body: some View {
        VStack {
            Text("You have disabled location services. Please provide custom coordinates for Drinkd to use by entering a latitude and longitude below. For a more streamlined experience, please enable location services.")
                .font(.title3)

            VStack(alignment: .leading) {

                Group {
                    Text("Please enter the latitude below")
                        .bold()
                        .padding(.top, 8)
                    TextField("Latitude", text: $latitude)
                }


                Group {
                    Text("Please enter the longitude below")
                        .bold()
                        .padding(.top, 8)
                    TextField("Longitude", text: $longitude)
                }

            }
            .padding()
            .textFieldStyle(Styles.regularTextFieldStyle())
            .keyboardType(.decimalPad)

            Button {

                guard let latitude = Double(self.latitude), let longitude = Double(self.longitude) else {
                    showAlert.state.toggle()
                    return
                }

                Task {
                    do {
                        try await Networking.shared.fetchUsingCustomLocation(viewModel: viewModel,longitude: longitude, latitude: latitude)
                    } catch {
                        showAlert.message = error.localizedDescription
                        showAlert.state.toggle()
                    }
                }

            } label: {
                Text("Submit")
                    .bold()
            }
            .buttonStyle(Styles.DefaultAppButton())

            Button {
                // Create the URL that deep links to your app's custom settings.
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    Task {
                        // Ask the system to open that URL.
                        await UIApplication.shared.open(url)
                    }

                }
            } label: {
                Text("Enable Location Services")
                    .bold()
            }
            .buttonStyle(Styles.DefaultAppButton())


            Spacer()
        }
        .alert("Error:", isPresented: $showAlert.state, actions: {}, message: {
            Text(showAlert.message)
        })
        .padding()
	}
}

#Preview {
    CustomLocationView()
        .environment(PartyViewModel())
}
