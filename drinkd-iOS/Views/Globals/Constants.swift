//
//  Constants.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 4/29/25.
//

import Foundation
import SwiftUI

struct Constants {

    //Hidden API KEY
    static let token: String = ProcessInfo.processInfo.environment["YELP_APIKEY"]!

    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone        
    }
}
