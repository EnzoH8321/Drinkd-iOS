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
struct AppLauncher {

    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            // Set user id on startup, if it does not already exist
            do {
               let _ = try UserDefaultsWrapper.getUserID
            } catch {
                UserDefaultsWrapper.setUserIDOnStartup()
            }

            Networking.shared.locationFetcher.start()
            drinkd_iOSApp.main()

        } else {
            TestApp.main()
        }
    }
}

struct TestApp: App {
    
    init() {

    }

    var body: some Scene {
        WindowGroup { Text("Running Unit Tests") }
    }
}


struct drinkd_iOSApp: App {

//	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	@State var viewModel = PartyViewModel()

	var body: some Scene {
		WindowGroup {
			MasterView()
				.environment(viewModel)
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in

                    Task {

                            let status = await ATTrackingManager.requestTrackingAuthorization()

                            switch status {
                            case .notDetermined:
                                Log.general.info("Not Determined")
                            case .restricted:
                                Log.general.info("Restricted Tracking")
                            case .denied:
                                Log.general.info("User has Denied Tracking")
                            case .authorized:
                                Log.general.info("User has Authorized Tracking")
                            @unknown default:
                                fatalError()
                            }

                        do {

                            do {
                                try await Networking.shared.rejoinParty(viewModel: viewModel)
                            } catch {
                                try await Networking.shared.updateRestaurants(viewModel: viewModel)
                            }

                        } catch {
                            Log.general.fault("Error fetching onReceive: \(error)")
                        }
                    }

                    Networking.shared.updateUserDeniedLocationServices()

				}
		}
	}
}



//TODO: Maybe get back to this, old code for push notifications.
// It's a UNUserNotificationCenterDelegate and you can think of it as a Notification Center. This is where all the notification actions are handled.
//@available(iOS 10, *)
//extension AppDelegate {
//
//	// Receive displayed notifications for iOS 10 devices.
//	func userNotificationCenter(_ center: UNUserNotificationCenter,
//								willPresent notification: UNNotification,
//								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//		let userInfo = notification.request.content.userInfo
//
//		if let messageID = userInfo[gcmMessageIDKey] {
//			print("Message ID: \(messageID)")
//		}
//
//		// Change this to your preferred presentation option
//		completionHandler([[.banner, .badge, .sound]])
//	}
//
//	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//	}
//
//	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//
//	}
//
//	func userNotificationCenter(_ center: UNUserNotificationCenter,
//								didReceive response: UNNotificationResponse,
//								withCompletionHandler completionHandler: @escaping () -> Void) {
//
//		let userInfo = response.notification.request.content.userInfo
//
//		if let messageID = userInfo[gcmMessageIDKey] {
//			print("Message ID from userNotificationCenter didReceive: \(messageID)")
//		}
//
//		completionHandler()
//	}
//}
