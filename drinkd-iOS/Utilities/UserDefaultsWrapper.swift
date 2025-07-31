//
//  UserDefaultsWrapper.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 5/10/25.
//

import Foundation
import drinkdSharedModels

final class UserDefaultsWrapper {

    static private let userID = "userID"

    private init() {}

    private static let defaults = UserDefaults.standard

    // User ID
    static func setUserIDOnStartup() {
        let id = UUID().uuidString
        defaults.set(id, forKey: userID)
    }

    static var getUserID: UUID {
        get throws {
            guard let uuidString = defaults.object(forKey: userID) as? String,
                  let uuid = UUID(uuidString: uuidString) else { throw SharedErrors.general(error: .userDefaultsError("Unable to find user ID")) }

            return uuid
        }
    }

}
