//
//  Button.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct YelpDetailButton: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.background(AppColors.primaryColor)
			.clipShape(Capsule())
	}
}

struct Button_Previews: PreviewProvider {
	static var previews: some View {
		Button("Test") {
			print("Test")
		}
		.buttonStyle(YelpDetailButton())
	}
}
