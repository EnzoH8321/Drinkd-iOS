//
//  UserDefaultsWrapper.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 5/10/25.
//

import Foundation

final class UserDefaultsWrapper {
    static let shared = UserDefaultsWrapper()
    private init() {}

    static let defaults = UserDefaults.standard

    static func setUserIDOnStartup() {
        let id = UUID().uuidString
        defaults.set(id, forKey: UserDefaultsKeys.userID.rawValue)
    }

    static func getUserID() -> UUID? {
        guard let uuidString = defaults.object(forKey: UserDefaultsKeys.userID.rawValue) as? String, let uuid = UUID(uuidString: uuidString) else { return nil }
        return uuid
    }
}

enum UserDefaultsKeys: String {
    case userID = "userID"
}
