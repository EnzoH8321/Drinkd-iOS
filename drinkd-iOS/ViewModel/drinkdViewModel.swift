//
//  drinkdViewModel.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import Foundation
import SwiftUI

class drinkdViewModel: ObservableObject {
	@State var removeSplashScreen = false
	@Published var model = drinkdModel()


}

