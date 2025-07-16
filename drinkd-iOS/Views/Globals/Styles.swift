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
	static let lowShadowRadius = CGFloat(2)
}

enum CardSpecificStyle {
	static let cornerRadius = CGFloat(25)
}
//For Device Type
enum DeviceType: String {
	case phone
	case ipad
}

//Button
enum ButtonSyling {
	static let frameHeight = CGFloat(5)
	static let clipShape = RoundedRectangle(cornerRadius: 10)
	static let buttonShadowColor = Color.black
	static let buttonShadowRadius = CGFloat(0)
	static let buttonShadowX = CGFloat(0)
	static let buttonShadowY = CGFloat(0)
	static let buttonTextColor = Color.white
}

struct Styles {

//    static var isPhone: Bool {
//        return Constants.isPhone
//    }

     struct DefaultAppButton: ButtonStyle {

        func makeBody(configuration: Configuration) -> some View {
            configuration
                .label
                .font( Constants.isPhone ? .body : .title2)
                .foregroundColor(ButtonSyling.buttonTextColor)
                .padding(Constants.isPhone ? 20 : 50)
                .frame(height: Constants.isPhone ? ButtonSyling.frameHeight : ButtonSyling.frameHeight + CGFloat(30))
                .padding()
                .background(AppColors.primaryColor)
                .clipShape(ButtonSyling.clipShape)
                .opacity(configuration.isPressed ? 0.5 : 1)
                .padding(20)
        }
    }

    struct CardInfoButton: ButtonStyle {

        func makeBody(configuration: Configuration) -> some View {
            configuration
                .label
                .font(Constants.isPhone ? .body : .title2)
                .foregroundColor(ButtonSyling.buttonTextColor)
                .padding(Constants.isPhone ? 20 : 35)
                .frame(height: Constants.isPhone ? ButtonSyling.frameHeight : ButtonSyling.frameHeight + CGFloat(10))
                .padding()
                .background(AppColors.primaryColor)
                .clipShape(ButtonSyling.clipShape)
                .shadow(color: configuration.isPressed ? Color.gray : ButtonSyling.buttonShadowColor, radius: ButtonSyling.buttonShadowRadius, x: ButtonSyling.buttonShadowX, y:  ButtonSyling.buttonShadowY)
                .opacity(configuration.isPressed ? 0.5 : 1)
        }
    }

    struct noPartyYelpButtonStyle: ButtonStyle {

        let deviceType: DeviceType

        func makeBody(configuration: Configuration) -> some View {
            configuration
                .label
                .font(deviceType == .phone ? .body : .title2)
                .foregroundColor(ButtonSyling.buttonTextColor)
                .padding(deviceType == .phone ? 0 : 15)
                .frame(height: deviceType == .phone ? 5 : ButtonSyling.frameHeight + CGFloat(40))
                .padding()
                .background(AppColors.primaryColor)
                .clipShape(ButtonSyling.clipShape)
                .shadow(color: configuration.isPressed ? Color.gray : ButtonSyling.buttonShadowColor, radius: ButtonSyling.buttonShadowRadius, x: ButtonSyling.buttonShadowX, y:  ButtonSyling.buttonShadowY)
                .opacity(configuration.isPressed ? 0.5 : 1)

        }
    }

    //TextField
    struct regularTextFieldStyle: TextFieldStyle {

        func _body(configuration: TextField<_Label>) -> some View {
                configuration
                .border(Color(UIColor.separator))
                .textFieldStyle(.roundedBorder)
            }
    }

    struct LabeledContentCardStyling: LabeledContentStyle {

        func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.label
                Spacer()
                configuration.content
                    .tint(Color.black)
            }
        }

    }


}









