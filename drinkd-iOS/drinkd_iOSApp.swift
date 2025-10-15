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

	var body: some Scene {
		WindowGroup {
			MasterView()
                .onAppear {
                    checkBuildCOnfiguration()
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
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in

                    Task {

                            let status = await ATTrackingManager.requestTrackingAuthorization()

                            switch status {
                            case .notDetermined:
                                Log.general.log("Not Determined")
                            case .restricted:
                                Log.general.log("Restricted Tracking")
                            case .denied:
                                Log.general.log("User has Denied Tracking")
                            case .authorized:
                                Log.general.log("User has Authorized Tracking")
                            @unknown default:
                                fatalError()
                            }

                        do {

                            do {
                                try await networking.rejoinParty(viewModel: viewModel)
                                try await networking.getRatedRestaurants(viewModel: viewModel)
                            } catch {
                                try await networking.updateRestaurants(viewModel: viewModel)
                            }

                        } catch {
                            Log.error.log("Error: \(error)")
                        }
                    }

                    networking.updateUserDeniedLocationServices()
				}
		}
	}

    private func checkBuildCOnfiguration() {
#if STAGING
        Log.general.log("⚠️ STAGING flag is defined")
#elseif DEVELOPMENT
        Log.general.log("⚠️ DEVELOPMENT flag is defined")
#else
        Log.general.log("✅ No flags defined - using production")
#endif
    }
}
