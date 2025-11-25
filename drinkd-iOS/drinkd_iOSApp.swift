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

	@State var viewModel = PartyViewModel()
    @State var networking = Networking()
    @State var yelpCache = YelpCache(nsCache: NSCache())

	var body: some Scene {
		WindowGroup {
			MasterView()
                .onAppear {
                    checkBuildConfiguration()
                    // Set user id on startup, if it does not already exist
                    do {
                       let _ = try UserDefaultsWrapper.getUserID
                    } catch {
                        UserDefaultsWrapper.setUserIDOnStartup()
                    }

                    networking.locationFetcher.start()
                }
				.environment(viewModel)
                .environment(networking)
                .environment(yelpCache)
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in

                    Task {

                        do {

                            do {
                                try await networking.rejoinParty(viewModel: viewModel)
                                try await networking.getRatedRestaurants(viewModel: viewModel)
                            } catch {
                                try await networking.updateRestaurants(cache: yelpCache, viewModel: viewModel)
                            }

                        } catch {
                            Log.error.log("Error: \(error)")
                        }
                    }

                    networking.updateUserDeniedLocationServices()
				}
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
