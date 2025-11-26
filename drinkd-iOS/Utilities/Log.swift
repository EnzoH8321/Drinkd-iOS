//
//  Log.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 8/7/25.
//

import Foundation
import OSLog

enum Log {

    private var subsystem: String {
        Bundle.main.bundleIdentifier!
    }

    case general
    case error

    /// Logs a message with file location context using the appropriate log level
    /// - Parameters:
    ///   - msg: Message to log
    ///   - file: Source file path
    ///   - line: Source line number
    func log(_ msg: String, file: String = #file, line: Int = #line) {
        // Extract filename from full path
        let fileName = (file as NSString).lastPathComponent

        // Log message based on log level type
        switch self {
        case .general:
            let logger = Logger(subsystem: subsystem, category: "General")
            logger.info("🧠 [\(fileName):\(line)] - \(msg)")
        case .error:
            let logger = Logger(subsystem: subsystem, category: "Error")
            logger.fault("⚠️ [\(fileName):\(line)] - \(msg)")
        }

    }

}
