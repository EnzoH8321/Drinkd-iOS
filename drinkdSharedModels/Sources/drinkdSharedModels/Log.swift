//
//  File.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/12/25.
//

import Foundation
//import OSLog
import Logging

public final class Log {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static let subsystem = Bundle.main.bundleIdentifier

//    public static let supabase = Logger(subsystem: subsystem ?? "Error locating Subsystem", category: "Supabase")
    public static let supabase = Logger(label: "\(subsystem ?? "Error locating Subsystem") category: Supabase")

//    public static let networking = Logger(subsystem: subsystem ?? "Error locating Subsystem", category: "Networking")
    public static let networking = Logger(label: "\(subsystem ?? "Error locating Subsystem") category: Networking")

//    public static let routes = Logger(subsystem: subsystem ?? "Error locating Subsystem", category: "Routes")
    public static let routes = Logger(label: "\(subsystem ?? "Error locating Subsystem") category: Routes")

//    public static let userDefaults = Logger(subsystem: subsystem ?? "Error locating Subsystem", category: "User Defaults")
    public static let userDefaults = Logger(label: "\(subsystem ?? "Error locating Subsystem") category: User Defaults")

//    public static let general = Logger(subsystem: subsystem ?? "Error locating Subsystem", category: "General")
    public static let general = Logger(label: "\(subsystem ?? "Error locating Subsystem") category: General")
}
