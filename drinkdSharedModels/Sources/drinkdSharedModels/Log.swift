//
//  File.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/12/25.
//

import Foundation
import OSLog

public final class Log {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static let subsystem = Bundle.main.bundleIdentifier

    public static let supabase = Logger(subsystem: subsystem ?? "Error locating Subsystem", category: "Supabase")

    public static let networking = Logger(subsystem: subsystem ?? "Error locating Subsystem", category: "Networking")

    public static let routes = Logger(subsystem: subsystem ?? "Error locating Subsystem", category: "Routes")


}
