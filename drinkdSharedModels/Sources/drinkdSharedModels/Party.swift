// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct Party {
    let partyLeaderID: String
    let partyID: String
    let partyMaxVotes : Int
    let partyName: String
    let timestamp: Int
    let url: String
    
    public init(partyLeaderID: String, partyID: String, partyMaxVotes: Int, partyName: String, timestamp: Int, url: String) {
        self.partyLeaderID = partyLeaderID
        self.partyID = partyID
        self.partyMaxVotes = partyMaxVotes
        self.partyName = partyName
        self.timestamp = timestamp
        self.url = url
    }
}
