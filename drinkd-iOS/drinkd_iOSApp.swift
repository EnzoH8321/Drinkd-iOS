//
//  drinkd_iOSApp.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI

@main
struct drinkd_iOSApp: App {
    let persistenceController = PersistenceController.shared

	var viewModel = drinkdViewModel()

    var body: some Scene {
        WindowGroup {
			MasterView(viewModel: self.viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
