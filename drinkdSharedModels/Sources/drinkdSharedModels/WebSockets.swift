//
//  WebSockets.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 6/1/25.
//
import Foundation

public struct WSMessage: Codable, Hashable, Identifiable {
    public let id: UUID
    public let text: String
    public let username: String
    public let timestamp: Date
    public let userID: UUID

    public init(id: UUID, text: String, username: String, timestamp: Date, userID: UUID) {
        self.text = text
        self.username = username
        self.timestamp = timestamp
        self.userID = userID
        self.id = id
    }
}
