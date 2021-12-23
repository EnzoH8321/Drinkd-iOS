//
//  Extensions.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/22/21.
//

import Foundation

extension Date {
	func currentTimeMillis() -> Int {
		return Int(self.timeIntervalSince1970 * 1000)
	}
}
