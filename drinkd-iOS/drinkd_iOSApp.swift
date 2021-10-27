//
//  drinkd_iOSApp.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI
import UIKit
import Firebase
import AppTrackingTransparency

@available(iOS 15.0, *)
@main
struct drinkd_iOSApp: App {

	init() {
		//Initializes firebase
		FirebaseApp.configure()
	}

	//	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

	let persistenceController = PersistenceController.shared

	@StateObject var viewModel = drinkdViewModel()

	var body: some Scene {
		WindowGroup {
			MasterView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
				.environmentObject(viewModel)
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
					if #available(iOS 14, *) {
						ATTrackingManager.requestTrackingAuthorization { status in
							switch (status) {
							case .authorized:
								viewModel.fetchRestaurantsOnStartUp()
								print("authorized")
							case .notDetermined:
								print("no determined")
							case .restricted:
								print("restricted")
							case .denied:
								print("denied")
								viewModel.fetchRestaurantsOnStartUp()
							@unknown default:
								print("unknown")
							}
						}
					} else {
						viewModel.fetchRestaurantsOnStartUp()
					}

				}

		}
	}
}



//class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
//
//	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//		//Sets Messaging delegate
//		Messaging.messaging().delegate = self
//		print("Your code here")
//
//
//		if #available(iOS 10.0, *) {
//			// For iOS 10 display notification (sent via APNS)
//			UNUserNotificationCenter.current().delegate = self
//
//			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//			UNUserNotificationCenter.current().requestAuthorization(
//				options: authOptions,
//				completionHandler: { _, _ in }
//			)
//		} else {
//			let settings: UIUserNotificationSettings =
//			UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//			application.registerUserNotificationSettings(settings)
//		}
//
//		application.registerForRemoteNotifications()
//
//		return true
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
//	func applicationWillTerminate(_ application: UIApplication) {
//		print("app ended")
//	}
//}
//
//extension AppDelegate: MessagingDelegate {
//
//	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//		//Monitor token refresh
//		print("Firebase registration token: \(String(describing: fcmToken))")
//
//		let dataDict: [String: String] = ["token": fcmToken ?? ""]
//
//		NotificationCenter.default.post(
//			name: Notification.Name("FCMToken"),
//			object: nil,
//			userInfo: dataDict
//		)
//		// TODO: If necessary send token to application server.
//		// Note: This callback is fired at each app startup and whenever a new token is generated.
//
//		// Fetching the current registration token
//		Messaging.messaging().token { token, error in
//			if let error = error {
//				print("Error fetching FCM registration token: \(error)")
//			} else if let token = token {
//				print("FCM registration token: \(token)")
//				//				self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
//			}
//		}
//
//	}
//}
//


