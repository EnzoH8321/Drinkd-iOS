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


