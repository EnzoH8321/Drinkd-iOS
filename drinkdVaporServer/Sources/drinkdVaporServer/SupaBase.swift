//
//  Constants.swift
//  drinkdVaporServer
//
//  Created by Enzo Herrera on 5/1/25.
//

import Foundation
import Supabase
import drinkdSharedModels

@Observable
final class SupaBase {
    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://jdkdtahoqpsspesqyojb.supabase.co")!,
        supabaseKey: ProcessInfo.processInfo.environment["SUPABASE_KEY"]!
    )

    // Manually deletes the party.
    // Only the party leader should be able to do this.
    private func manuallyDeleteParty(userID: UUID, partyID: UUID) async throws {

        do {
            // Check if the party still exists in the parties table & if the person deleting is the party leader
            let matches = try await checkMatching(tableType: .parties, dictionary: ["party_leader": userID])

            if matches {
                // Happy Path
                try await deleteDataFromTable(fromTable: .parties, rowID: partyID, userID: userID)
            }

        } catch {
            print("Unable to Delete Party due to error - \(error)")
            throw error
        }
    }



    // Dictionary represents filters. [column name: value to filter for]
    // Returns true if the provided dictionary matches any data in the provided table.
    // By default returns false
    private func checkMatching(tableType: TableTypes, dictionary: [String: any PostgrestFilterValue] = [:]) async throws -> Bool {

        let columnsToFilterFor: String = dictionary.keys.map {"\($0)"}.joined(separator: "'")
        let response = try await client
            .from(tableType.tableName)
            .select(dictionary.count == 0 ? "*" : columnsToFilterFor)
            .match(dictionary)
            .execute()

        do {
            switch tableType {

            case .parties:

                let partiesArray = try JSONDecoder().decode([PartiesTable].self, from: Data(response.data))
                return partiesArray.count > 0 ? true : false

            case .users:

                let usersArray = try JSONDecoder().decode([UsersTable].self, from: Data(response.data))
                return usersArray.count > 0 ? true : false

            case .messages:
                let messagesArray = try JSONDecoder().decode([MessagesTable].self, from: Data(response.data))
                return messagesArray.count > 0 ? true : false
            }

        } catch {
            throw error
        }

    }
    // Upsert a row to a table
    // Upsert inserts a new row if one does not exist, otherwise update it
    private func upsertDataToTable<T: SupaBaseTable>(tableType: TableTypes, data: T) async throws {

        do {

            switch tableType {
            case .parties:

                guard let partyData = data as? PartiesTable else { throw SharedErrors.General.castingError("Unable to convert data to PartiesTable") }

                try await client.from(tableType.tableName).upsert(partyData).execute()
            case .users:
                guard let usersData = data as? UsersTable else { throw SharedErrors.General.castingError("Unable to convert data to UsersTable") }

                try await client.from(tableType.tableName).upsert(usersData).execute()

            case .messages:
                guard let messagesData = data as? MessagesTable else { throw SharedErrors.General.castingError("Unable to convert data to MessagesTable")}

                try await client.from(tableType.tableName).upsert(messagesData).execute()
            }

        } catch {
            print("Error - \(error)")
            throw error
        }

    }

    // Delete a row in a table
    private func deleteDataFromTable(fromTable: TableTypes, rowID: UUID, userID: UUID? = nil) async throws {

        switch fromTable {
        case .parties:

            guard let validLeaderID = userID else {
                print("Invalid Leader ID passed in")
                return
            }

            do {
                try await client.from(fromTable.tableName).delete().eq("party_leader", value: validLeaderID).execute()
            } catch {
                throw error
            }

        case .users:
            do {
                try await client.from(fromTable.tableName).delete().eq("id", value: rowID).execute()
            } catch {
                throw error
            }
        case .messages:
            do {
                try await client.from(fromTable.tableName).delete().eq("id", value: rowID).execute()
            } catch {
                throw error
            }
        }


    }

    func fetchRow(tableType: TableTypes, dictionary: [String: any PostgrestFilterValue] = [:]) async throws -> [any SupaBaseTable] {
        let columnsToFilterFor: String = dictionary.keys.map {"\($0)"}.joined(separator: "'")
        let response = try await client
            .from(tableType.tableName)
            .select()
            .match(dictionary)
            .execute()

        do {
            switch tableType {

            case .parties:

                let partiesArray = try JSONDecoder().decode([PartiesTable].self, from: Data(response.data))
                return partiesArray

            case .users:

                let usersArray = try JSONDecoder().decode([UsersTable].self, from: Data(response.data))
                return usersArray
            case .messages:
                let messagesArray = try JSONDecoder().decode([MessagesTable].self, from: Data(response.data))
                return messagesArray
            }

        } catch {
            throw error
        }
    }

}

//MARK: Specific - Parties Table
extension SupaBase {
    func addMemberToParty(partyID: UUID, userID: UUID) async throws {
//        try await client.from(TableTypes.parties.tableName).update(<#T##values: Encodable & Sendable##Encodable & Sendable#>)
    }
}


//MARK: Routes Calls
extension SupaBase {

    /// Creates a Party
    func createAParty(leaderID: UUID, userName: String) async throws -> PartiesTable {
        do {

            // Add to Parties Table
            let randomInt = Int.random(in: 100000..<999999)
            let partyID = UUID()
            let party = PartiesTable(id: partyID, partyLeader: leaderID, date_created: Date().ISO8601Format(), code: randomInt)
            // Add to Party Members Table
            try await client.from(TableTypes.parties.tableName).upsert(party).execute()

            // Add to Users Table
            let user = UsersTable(id: leaderID, username: userName, date_created: Date().ISO8601Format(), memberOfParty: partyID)
            try await client.from(TableTypes.users.tableName).upsert(user).execute()

            
            return party
        } catch {
            print("Error - \(error)")
            throw error
        }

    }

    // Leave a party
    func leaveParty(userID: UUID, partyID: UUID) async throws {

        do {
            // Check if party leader
            let isPartyLeader = try await checkMatching(tableType: .parties, dictionary: ["party_leader": userID])

            // Path for leader
            if isPartyLeader {
                // Delete Party
               try await manuallyDeleteParty(userID: userID, partyID: partyID)
                // Delete User
                // For users, the row id is the user id
               try await deleteDataFromTable(fromTable: .users, rowID: userID)

            } else {
                // Path for Guest
                try await deleteDataFromTable(fromTable: .users, rowID: userID)

            }

        } catch {
            print(error)
            throw error
        }
    }

    // Join a Party
    // Only works if you are not party leader, a party leader cannot join a party
    // Party Code should be six digits.
    // User should not be in another party
    func joinParty(username: String, partyCode: Int) async throws -> PartiesTable {
//        let user = UsersTable(id: UUID(), username: username, date_created: Date().ISO8601Format(), memberOfParty: nil)
        // Check that party code is six digits
        if partyCode < 100000 || partyCode > 999999 {
            throw SharedErrors.SupaBase.invalidPartyCode
        }

        // Find party using the party code
        do {

            guard let row = try await fetchRow(tableType: .parties, dictionary: ["code": partyCode]) as? [PartiesTable] else {
                throw SharedErrors.General.castingError("Unable to cast row as parties table")
            }

            guard let partyTable = row.first else {
                throw SharedErrors.supabase(error: .rowIsEmpty)
            }

            guard let validPartyID = partyTable.id else {
                throw SharedErrors.supabase(error: .dataNotFound)
            }



            // Happy Path, party exists with that code, get party ID
            let partyID = validPartyID
            let userID = UUID()
            let user = UsersTable(id: userID, username: username, date_created: Date().ISO8601Format(), memberOfParty: partyID)
            // Add to users table. This user will have a foreign key that traces back to the party
            try await upsertDataToTable(tableType: .users, data: user)

            return partyTable

        } catch {
            throw error
        }
    }

    func sendMessage(userID: UUID, text: String) async throws {

        do {
            // We need to get the party ID from the user row
            guard let users = try await fetchRow(tableType: .users, dictionary: ["id": userID]) as? [UsersTable] else {
                throw SharedErrors.General.castingError("Unable to cast row as users table")
            }

            guard let user = users.first else {
                print("users are empty")
                return
            }

            let partyID = user.party_id
            let message = MessagesTable(id: UUID(), partyId: partyID, date_created: Date().ISO8601Format(), text: text, userId: userID)

            // Add message to messages table
            try await upsertDataToTable(tableType: .messages, data: message)

        } catch {
            throw error
        }




    }

    // Creates a User
    // Users are tied to parties
    // User is created on the server.
    // Only thing client should provide is the username
    // When a person leaves a party, the user should be destroyed
//    func createUser(username: String) -> UsersTable {
//        return UsersTable(id: UUID(), username: username, date_created: Date().ISO8601Format(), memberOfParty: nil)
//    }
}
