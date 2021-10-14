//
//  Global.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import Foundation
import SwiftUI

enum AppColors {
	//use fractions to make it over 1
	static let primaryColor: Color = Color(red: 233 / 255, green: 29 / 255, blue: 27 / 255)
}

enum AppShadow {
	static let mediumShadowRadius = CGFloat(10)
	static let lowShadowRadius = CGFloat(10)
}

enum CardSpecificStyle {
	static let cornerRadius = CGFloat(25)
}

enum ButtonSyling {
	static let frameHeight = CGFloat(20)
	static let clipShape = Capsule()
	static let buttonShadowColor = Color.black
	static let buttonShadowRadius = CGFloat(4)
	static let buttonShadowX = CGFloat(2)
	static let buttonShadowY = CGFloat(1)
	static let buttonTextColor = Color.black
}
