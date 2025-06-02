//
//  WebSockets.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 6/1/25.
//


public struct WSMessage: Codable, Hashable {
    public let text: String

    public init(text: String) {
        self.text = text
    }
}
