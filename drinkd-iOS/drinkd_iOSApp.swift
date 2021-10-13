//
//  drinkd_iOSApp.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI
import UIKit
import Firebase

@available(iOS 15.0, *)
@main
struct drinkd_iOSApp: App {

	init() {
		//Initializes firebase
		FirebaseApp.configure()
		
	}

	let persistenceController = PersistenceController.shared

	@StateObject var viewModel = drinkdViewModel()
	
	var body: some Scene {
		WindowGroup {
			MasterView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
				.environmentObject(viewModel)
//				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//					print("app has started")
//				}
		}

		
	}
}


//class AppDelegate: NSObject, UIApplicationDelegate {
//	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//		print("Your code here")
//		return true
//	}
//
//	func applicationWillTerminate(_ application: UIApplication) {
//		print("app ended")
//	}
//
//
//
//	// Implement other methods that you require.
//
//}
