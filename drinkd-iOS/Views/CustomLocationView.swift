//
//  CustomLocationView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/26/21.
//

import SwiftUI

struct CustomLocationView: View {

    @Environment(PartyViewModel.self) var viewModel

    @State private var showAlert: (message: String, state: Bool) = ("", false)

    private var latitude: Binding<String> {
        Binding {
            return String(viewModel.customLat)
        } set: {
            viewModel.customLat = Double($0) ?? 0
        }

    }

    private var longitude: Binding<String> {
        Binding {
            return String(viewModel.customLong)
        } set: {
            viewModel.customLong = Double($0) ?? 0
        }

    }

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
                    TextField("Latitude", text: latitude)
                }


                Group {
                    Text("Please enter the longitude below")
                        .bold()
                        .padding(.top, 8)
                    TextField("Longitude", text: longitude)
                }

            }
            .padding()
            .textFieldStyle(Styles.regularTextFieldStyle())
            .keyboardType(.decimalPad)

            Button {

                Task {
                    do {
                        try await Networking.shared.fetchRestaurants(viewModel: viewModel, latitude: viewModel.customLat, longitude: viewModel.customLong)
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
