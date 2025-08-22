//
//  SplashScreen.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/27/21.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {

        ZStack {

            Color(red: 240/255, green: 240/255, blue: 240/255)
                .ignoresSafeArea()

            Image("drinkdLogo")
                .resizable()
                .scaledToFit()
        }


    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
