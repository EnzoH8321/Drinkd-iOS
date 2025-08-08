//
//  Utilities.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 8/8/25.
//

import Foundation
@testable import drinkd_iOS

final class Utilities {

    static func createBusinessSearchProperties() -> YelpApiBusinessSearchProperties? {
//        guard let file = Bundle.main.url(forResource: "MockYelpBusinessSearchProperties", withExtension: "json") else {
//            TestLog.error.log("Unable to find file")
//            return nil
//        }
        // Get the test bundle (where your test files are)
        let bundle = Bundle(for: Utilities.self)
        guard let file = bundle.url(forResource: "MockYelpBusinessSearchProperties", withExtension: "json") else {
            TestLog.error.log("Unable to find file")
            return nil
        }

        do {
            let data = try Data(contentsOf: file)
            let searchProperties = try JSONDecoder().decode(YelpApiBusinessSearchProperties.self, from: data)
            return searchProperties
        } catch {
            TestLog.error.log("Error parsing data file: \(error)")
            return nil
        }

    }

}
