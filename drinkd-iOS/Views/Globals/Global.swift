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
	static let secondColor: Color = Color(red: 255 / 255, green: 204 / 255, blue: 0 / 255)
}

enum AppShadow {
	static let mediumShadowRadius = CGFloat(10)
	static let lowShadowRadius = CGFloat(4)
}

enum CardSpecificStyle {
	static let cornerRadius = CGFloat(25)
}
//For Device Type
enum DeviceType: String {
	case phone
	case ipad
}

enum UserPrivacyChoice {
	case userApprovedTracking
	case userDeniedTracking
}

//Button
enum ButtonSyling {
	static let frameHeight = CGFloat(20)
	static let clipShape = Capsule()
	static let buttonShadowColor = Color.black
	static let buttonShadowRadius = CGFloat(4)
	static let buttonShadowX = CGFloat(2)
	static let buttonShadowY = CGFloat(1)
	static let buttonTextColor = Color.black
}

struct DefaultAppButton: ButtonStyle {

	let deviceType: DeviceType

	func makeBody(configuration: Configuration) -> some View {
		configuration
			.label
			.font(deviceType == .phone ? .body : .title2)
			.foregroundColor(ButtonSyling.buttonTextColor)
			.padding(deviceType == .phone ? 20 : 50)
			.frame(height: deviceType == .phone ? ButtonSyling.frameHeight : ButtonSyling.frameHeight + CGFloat(30))
			.padding()
			.background(AppColors.primaryColor)
			.clipShape(ButtonSyling.clipShape)
			.shadow(color: configuration.isPressed ? Color.gray : ButtonSyling.buttonShadowColor, radius: ButtonSyling.buttonShadowRadius, x: ButtonSyling.buttonShadowX, y:  ButtonSyling.buttonShadowY)
			.opacity(configuration.isPressed ? 0.5 : 1)
			.padding(20)
	}
}

struct CardInfoButton: ButtonStyle {

	let deviceType: DeviceType

	func makeBody(configuration: Configuration) -> some View {
		configuration
			.label
			.font(deviceType == .phone ? .body : .title2)
			.foregroundColor(ButtonSyling.buttonTextColor)
			.padding(deviceType == .phone ? 20 : 35)
			.frame(height: deviceType == .phone ? ButtonSyling.frameHeight : ButtonSyling.frameHeight + CGFloat(10))
			.padding()
			.background(AppColors.primaryColor)
			.clipShape(ButtonSyling.clipShape)
			.shadow(color: configuration.isPressed ? Color.gray : ButtonSyling.buttonShadowColor, radius: ButtonSyling.buttonShadowRadius, x: ButtonSyling.buttonShadowX, y:  ButtonSyling.buttonShadowY)
			.opacity(configuration.isPressed ? 0.5 : 1)
	
	}
}

struct LargeCardInfoButton: ButtonStyle {

	let deviceType: DeviceType

	func makeBody(configuration: Configuration) -> some View {
		configuration
			.label
			.font(deviceType == .phone ? .body : .title2)
			.foregroundColor(ButtonSyling.buttonTextColor)
			.padding(deviceType == .phone ? 20 : 35)
			.frame(height: deviceType == .phone ? ButtonSyling.frameHeight + 30 : ButtonSyling.frameHeight + CGFloat(40))
			.padding()
			.background(AppColors.primaryColor)
			.clipShape(ButtonSyling.clipShape)
			.shadow(color: configuration.isPressed ? Color.gray : ButtonSyling.buttonShadowColor, radius: ButtonSyling.buttonShadowRadius, x: ButtonSyling.buttonShadowX, y:  ButtonSyling.buttonShadowY)
			.opacity(configuration.isPressed ? 0.5 : 1)

	}
}
