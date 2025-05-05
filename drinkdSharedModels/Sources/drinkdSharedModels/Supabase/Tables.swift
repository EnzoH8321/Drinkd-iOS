
//
//  Untitled.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/4/25.
//

import Foundation

public enum TableTypes {
    case parties
    case users

    public var tableName: String {
        switch self {
        case .parties:
            return "Parties"
        case .users:
            return "Users"
        }
    }
}

public protocol SupaBaseTable {

}


// For tables
public struct PartiesTable: Codable, Sendable, SupaBaseTable {
    let id: UUID?
    let date_created: String?
    let party_leader: UUID?
    let members: [UUID]?
    let code: Int?

    public init(id: UUID, partyLeader: UUID, date_created: String, members: [UUID], code: Int) {
        self.id = id
        self.party_leader = partyLeader
        self.date_created = date_created
        self.members = members
        self.code = code
    }
}

public struct UsersTable: Codable, Sendable, SupaBaseTable {
    let id: UUID
    let date_created: String
    let username: String

    public init(id: UUID, username: String, date_created: String) {
        self.id = id
        self.username = username
        self.date_created = date_created
    }
}
