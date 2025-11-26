//
//  UserDefaultsWrapper.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 5/10/25.
//

import Foundation
import drinkdSharedModels

@MainActor
final class UserDefaultsWrapper {

    static private let userID = "userID"

    private init() {}

    private static let defaults = UserDefaults.standard

    /// Generates and stores a new user ID in UserDefaults
    static func setUserID() {
        let id = UUID().uuidString
        defaults.set(id, forKey: userID)
    }

    /// Retrieves the stored user ID from UserDefaults as a UUID
    /// - Returns: The user's UUID
    /// - Throws: Error if user ID is not found or cannot be converted to a UUID
    static var getUserID: UUID {
        get throws {
            // Extract UUID string from UserDefaults and convert to UUID
            guard let uuidString = defaults.object(forKey: userID) as? String,
                  let uuid = UUID(uuidString: uuidString) else { throw UserDefaultsErrors.noUserID(msg: "Unable to find user ID") }

            return uuid
        }
    }

}
