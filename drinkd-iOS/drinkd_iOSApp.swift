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
struct AppLauncher {

    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            FirebaseApp.configure()
            // Set user id on startup, if it does not already exist
            if UserDefaultsWrapper.getUserID() == nil {
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
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup { Text("Running Unit Tests") }
    }
}


struct drinkd_iOSApp: App {

	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	let persistenceController = PersistenceController.shared

	@State var viewModel = PartyViewModel()
    @State var showErrorAlert = false

	var body: some Scene {
		WindowGroup {
			MasterView()
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Error Retrieving User Location"), primaryButton: .default(Text("Retry"), action: {
                        Networking.shared.updateUserDeniedLocationServices()
                        Networking.shared.fetchRestaurantsOnStartUp(viewModel: viewModel) { result in

                            switch(result) {
                            case .success(_):
                                print("Success, initial data fetch was successful")
                            case .failure(_):
                                print("Failed, initial data fetch was unsuccessful")
                                Networking.shared.updateUserDeniedLocationServices()
                            }

                        }
                    }), secondaryButton: .cancel())
                }
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
				.environment(viewModel)
				.onAppear {
					//TODO: We have to add this because its the only way for ios 14 to actually fetch data
					if (Constants.isPhone) {
						if #available(iOS 13, *) {
                            Networking.shared.updateUserDeniedLocationServices()
                            Networking.shared.fetchRestaurantsOnStartUp(viewModel: viewModel) { result in

								switch(result) {
								case .success(_):
									print("Success, initial data fetch was successful")
                            
								case .failure(_):
									print("Failed, initial data fetch was unsuccessful")
                                    //If it fails and user manually chooses to not share location, set the Alert and retry fetching the restaurants.
                                    if (!Networking.shared.userDeniedLocationServices) {
                                        showErrorAlert = true
                                    }
								}
							}
						}
					}

				}
                
			//TODO: From some reason, on receive glitches on iOS 14. Not called for some reason. During INIT OF IOS 14, you do have to put api call here or else it does not automatically do a call :(
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in

					//TODO: We do this because on iPAD fetching on ios14 only works in on receive.... ipad ios 15 works normally
					if (!Constants.isPhone) {
                        Networking.shared.fetchRestaurantsOnStartUp(viewModel: viewModel) { result in

							switch(result) {
							case .success(_):
								print("Success")
                                self.showErrorAlert = false
							case .failure(_):
								print("Failed")
							}

						}
                        Networking.shared.updateUserDeniedLocationServices()
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
					if (Constants.isPhone) {
                        Networking.shared.fetchRestaurantsOnStartUp(viewModel: viewModel) { result in

							switch(result) {
							case .success(_):
								print("Success")
                                self.showErrorAlert = false
							case .failure(_):
								print("Failed")
							}

						}
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

		completionHandler()
	}
}
