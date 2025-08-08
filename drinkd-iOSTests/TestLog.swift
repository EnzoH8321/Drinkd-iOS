//
//  Log.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 8/8/25.
//

import Foundation

import Foundation
import OSLog

enum TestLog {

    private var subsystem: String {
        Bundle.main.bundleIdentifier!
    }

    case general
    case error

    func log(_ msg: String, file: String = #file, line: Int = #line) {

        let fileName = (file as NSString).lastPathComponent

        switch self {
        case .general:
            let logger = Logger(subsystem: subsystem, category: "General")
            logger.info("[\(fileName):\(line)] - \(msg)")
        case .error:
            let logger = Logger(subsystem: subsystem, category: "Error")
            logger.fault("[\(fileName):\(line)] - \(msg)")
        }

    }

}
