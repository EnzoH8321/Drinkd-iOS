//
//  Constants.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 4/29/25.
//

import Foundation
import SwiftUI
import ConfidentialKit

struct Constants {

    //Hidden API KEYS
    static let yelpToken: String = "\(Secrets.$yelpKey)"
    static let supabaseToken: String = "\(Secrets.$supabaseKey)"
}

enum NetworkSuccess {
    case connectionSuccess
}
