//
//  CustomLocationView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/26/21.
//

import SwiftUI
import drinkdSharedModels

struct CustomLocationView: View {

    @Environment(PartyViewModel.self) var viewModel
    @Environment(Networking.self) var networking
    @State private var showAlert: (message: String, state: Bool) = ("", false)

	var body: some View {
        @Bindable var viewModel = viewModel
        VStack {
            Text("You have disabled location services. Please provide custom coordinates for Drinkd to use by entering a latitude and longitude below. For a more streamlined experience, please enable location services.")
                .font(.title3)

            VStack(alignment: .leading) {

                Group {
                    Text("Please enter the latitude below")
                        .bold()
                        .padding(.top, 8)

                    TextField("Latitude", value: $viewModel.customLat, format: .number)
                }

                Group {
                    Text("Please enter the longitude below")
                        .bold()
                        .padding(.top, 8)
                    TextField("Longitude", value: $viewModel.customLong, format: .number)
                }

            }
            .padding()
            .textFieldStyle(Styles.regularTextFieldStyle())

            Button {

                Task {
                    do {

                       // Assume user is currently not on Null Island
                        if viewModel.customLong == 0 && viewModel.customLat == 0 {
                            throw SharedErrors.general(error: .missingValue("Invalid Latitude and/or Longitude"))
                        }

                        try await networking.updateRestaurants(viewModel: viewModel, longitude: viewModel.customLong, latitude: viewModel.customLat)
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
        .environment(Networking())
}
