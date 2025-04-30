// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct Party {
    public let partyLeaderID: String
    public let partyID: String
    public let partyMaxVotes : Int
    public let partyName: String
    public let timestamp: Int
    public let url: String

    public init(partyLeaderID: String, partyID: String, partyMaxVotes: Int, partyName: String, timestamp: Int, url: String) {
        self.partyLeaderID = partyLeaderID
        self.partyID = partyID
        self.partyMaxVotes = partyMaxVotes
        self.partyName = partyName
        self.timestamp = timestamp
        self.url = url
    }
}
