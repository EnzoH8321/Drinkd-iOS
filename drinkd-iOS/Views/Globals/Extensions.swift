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

	//Formats the timestamp to a human readable date
	func formatDate(forMilliseconds milliseconds: Int) -> String {
		//Format Date
		let dateVar = Date(timeIntervalSince1970: TimeInterval( milliseconds / 1000))
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd-MM-yyyy hh:mm"
		let dateString = dateFormatter.string(from: dateVar)

		return dateString
	}
}
