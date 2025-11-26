//
//  drinkd_iOSApp.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI
import UIKit
import AppTrackingTransparency
import UserNotifications
import drinkdSharedModels

@main
struct drinkd_iOSApp: App {

    @State var locationManager = LocationManager()
	@State var viewModel = PartyViewModel()
    @State var networking = Networking()
    @State var yelpCache = YelpCache(nsCache: NSCache())

	var body: some Scene {
		WindowGroup {
			MasterView()
                .onAppear {
                    checkBuildConfiguration()
                    getUserID()
                    locationManager.requestWhenInUseAuthorization()
                }
				.environment(viewModel)
                .environment(networking)
                .environment(yelpCache)
                .environment(locationManager)
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in

                    Task {

                        do {

                            do {
                                try await networking.rejoinParty(viewModel: viewModel)
                                try await networking.getRatedRestaurants(viewModel: viewModel)
                            } catch {
                                try await networking.updateRestaurants(cache: yelpCache, viewModel: viewModel, locationManager: locationManager)
                            }

                        } catch {
                            Log.error.log("Error: \(error)")
                        }
                    }

				}
		}
	}
    /// Get's the user's ID from `UserDefaults` if possible. Otherwise, create a new user ID and set it.
    private func getUserID() {
        do {
           let _ = try UserDefaultsWrapper.getUserID
        } catch {
            UserDefaultsWrapper.setUserIDOnStartup()
        }
    }

    // Checks Build Config
    private func checkBuildConfiguration() {
#if STAGING
        Log.general.log("⚠️ STAGING flag is defined")
#elseif DEBUG
        Log.general.log("⚠️ DEBUG flag is defined")
#else
        Log.general.log("✅ No flags defined - using production")
#endif
    }
}
