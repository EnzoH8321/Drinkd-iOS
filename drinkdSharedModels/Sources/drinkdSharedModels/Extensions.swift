//
//  File.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 7/25/25.
//

import Foundation

extension String {
    public func fromPostgreSQLTimestamp() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.date(from: self)
    }
}
