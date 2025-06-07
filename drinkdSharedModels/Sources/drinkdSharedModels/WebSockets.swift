//
//  WebSockets.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 6/1/25.
//
import Foundation

public struct WSMessage: Codable, Hashable {
    public let text: String
    public let username: String
    public let timestamp: Date

//    public init(text: String) {
//        self.text = text
//    }

    public init(text: String, username: String, timestamp: Date) {
        self.text = text
        self.username = username
        self.timestamp = timestamp
    }
}
