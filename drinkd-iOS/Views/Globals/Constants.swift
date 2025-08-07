//
//  Constants.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 4/29/25.
//

import Foundation
import SwiftUI

struct Constants {

    //Hidden API KEYS
    static let yelpToken: String = ProcessInfo.processInfo.environment["YELP_APIKEY"]!
    static let supabaseToken: String = ProcessInfo.processInfo.environment["SUPABASE_KEY"]!
}

enum NetworkSuccess {
    case connectionSuccess
}
