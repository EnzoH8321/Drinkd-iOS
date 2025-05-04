
//
//  Untitled.swift
//  drinkdSharedModels
//
//  Created by Enzo Herrera on 5/4/25.
//

import Foundation

public enum TableTypes {
    case parties

    public var tableName: String {
        switch self {
        case .parties:
            return "Parties"
        }
    }
}

public protocol SupaBaseTable {

}


// For tables
public struct PartiesTable: Codable, Sendable, SupaBaseTable {
    let id: UUID
    let date_created: String
    let members: [UUID]
    let chat: UUID
    let code: Int

    public init(id: UUID, date_created: String, members: [UUID], chat: UUID, code: Int) {
        self.id = id
        self.date_created = date_created
        self.members = members
        self.chat = chat
        self.code = code
    }
}
