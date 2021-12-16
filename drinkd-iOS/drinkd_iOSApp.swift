//
//  drinkd_iOSApp.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseMessaging
import AppTrackingTransparency
import UserNotifications


@main
struct drinkd_iOSApp: App {

	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	let persistenceController = PersistenceController.shared

	@StateObject var viewModel = drinkdViewModel()

	var body: some Scene {
		WindowGroup {
			MasterView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
				.environmentObject(viewModel)
				.onAppear {
					//					fetchRestaurantsOnStartUp(viewModel: viewModel)

					//TODO: We have to add this because its the only way for ios 14 to actually fetch data
					if (viewModel.isPhone) {
						if #available(iOS 13, *) {
							viewModel.setuserLocationError()
							fetchRestaurantsOnStartUp(viewModel: viewModel)
						}
					}



				}
			//TODO: From some reason, on receive glitches on iOS 14. Not called for some reason. During INIT OF IOS 14, you do have to put api call here or else it does not automatically do a call :(
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
					//					fetchRestaurantsOnStartUp(viewModel: viewModel)
					//					viewModel.setuserLocationError()

					//TODO: We do this because on iPAD fetching on ios14 only works in on receive.... ipad ios 15 works normally
					if (!viewModel.isPhone) {
						fetchRestaurantsOnStartUp(viewModel: viewModel)
						viewModel.setuserLocationError()
					}

					if #available(iOS 14, *) {

						ATTrackingManager.requestTrackingAuthorization { status in
							switch (status) {
							case .authorized:
								print("User has Authorized Tracking")
							case .notDetermined:
								print("Not Determined")
							case .restricted:
								print("Restricted Tracking")

							case .denied:
								print("User has Denied Tracking")

							@unknown default:
								print("Unknown")
							}
						}
					}
					//TODO: For ios 14 to fetch during first time startup, you must put this code here. After initial startup, ios 14 will never call this code again....
					if (viewModel.isPhone) {
						fetchRestaurantsOnStartUp(viewModel: viewModel)
					}

					
				}
		}
	}
}

//The first one is executed once the app finished launching. We are configuring Firebase, then asking the user for permission to send them push notifications.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate, ObservableObject {
	let gcmMessageIDKey = "gcm.message_id"
	static var fcmToken: String = "TestTOKEN"

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {



		FirebaseApp.configure()

		Messaging.messaging().delegate = self

		if #available(iOS 10.0, *) {
			//FOR IOS 10 DISPLAY NOTIFICATION
			UNUserNotificationCenter.current().delegate = self
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_,_ in})
		} else {
			let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			application.registerUserNotificationSettings(settings)
		}

		application.registerForRemoteNotifications()
		return true
	}

	//The second function listens to remote notifications and will alert the app when a new push notification comes in.
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
					 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}

		print(userInfo)

		completionHandler(UIBackgroundFetchResult.newData)
	}

	//The messaging() function inside of this extension will print the device token. It'll be useful when we'll be sending a test notification through the Firebase Cloud Messaging Console to our device.
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		let deviceToken: [String: String] = ["token": fcmToken ?? "TOKEN NOT FOUND"]

		AppDelegate.fcmToken = deviceToken["token"] ?? "NO TOKEN"

		print("Device token: ", deviceToken) // This token can be used for testing notifications on FCM
	}

}


// It's a UNUserNotificationCenterDelegate and you can think of it as a Notification Center. This is where all the notification actions are handled.
@available(iOS 10, *)
extension AppDelegate {

	// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

		let userInfo = notification.request.content.userInfo

		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}

		// Change this to your preferred presentation option
		completionHandler([[.banner, .badge, .sound]])
	}

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

	}

	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {

		let userInfo = response.notification.request.content.userInfo

		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID from userNotificationCenter didReceive: \(messageID)")
		}

		print(userInfo)

		completionHandler()
	}
}
