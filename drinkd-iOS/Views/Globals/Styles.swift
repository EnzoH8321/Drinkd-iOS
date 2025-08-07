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

//Button
enum ButtonSyling {
	static let frameHeight = CGFloat(5)
	static let clipShape = RoundedRectangle(cornerRadius: 10)
	static let buttonTextColor = Color.white
}

struct Styles {

    struct DefaultAppButton: ButtonStyle {

        func makeBody(configuration: Configuration) -> some View {
            configuration
                .label
                .font(.body)
                .foregroundColor(ButtonSyling.buttonTextColor)
                .padding()
                .background(AppColors.primaryColor)
                .clipShape(ButtonSyling.clipShape)
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









