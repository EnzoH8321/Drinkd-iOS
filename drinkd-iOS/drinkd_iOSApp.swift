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
		ref = Database.database().reference()
	}

	let persistenceController = PersistenceController.shared

	@StateObject var viewModel = drinkdViewModel()

	//Firebase
	var ref: DatabaseReference!

	var body: some Scene {
		WindowGroup {
			MasterView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
				.environmentObject(viewModel)
		}
	}
}


