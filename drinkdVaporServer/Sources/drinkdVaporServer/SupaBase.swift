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

        do {
            switch tableType {

            case .parties:
                let response = try await client
                    .from(tableType.tableName)
                    .select(dictionary.count == 0 ? "*" : columnsToFilterFor)
                    .match(dictionary)
                    .execute()

                let partiesArray = try JSONDecoder().decode([PartiesTable].self, from: Data(response.data))

                return partiesArray.count > 0 ? true : false

            case .users:
                let response = try await client
                    .from(tableType.tableName)
                    .select(dictionary.count == 0 ? "*" : columnsToFilterFor)
                    .match(dictionary)
                    .execute()

                let usersArray = try JSONDecoder().decode([UsersTable].self, from: Data(response.data))

                return usersArray.count > 0 ? true : false
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

                guard let partyData = data as? PartiesTable else { throw Errors.SupaBase.Data.castingError }

                try await client.from(tableType.tableName).upsert(partyData).execute()
            case .users:
                guard let usersData = data as? UsersTable else { throw Errors.SupaBase.Data.castingError }

                try await client.from(tableType.tableName).upsert(usersData).execute()
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
                print("Error - \(error)")
                throw error
            }

        case .users:
            do {
                try await client.from(fromTable.tableName).delete().eq("id", value: rowID).execute()
            } catch {
                print("Error - \(error)")
                throw error
            }
        }


    }
}

// Routes Calls
extension SupaBase {

    /// Creates a Party
    func createAParty(leaderID: UUID, userName: String) async throws {
        do {
            // Add to Users Table
            let user = UsersTable(id: leaderID, username: userName, date_created: Date().ISO8601Format())
            try await client.from(TableTypes.users.tableName).upsert(user).execute()
            // Add to Parties Table
            let randomInt = Int.random(in: 100000..<999000)
            let party = PartiesTable(id: UUID(), partyLeader: leaderID, date_created: Date().ISO8601Format(), members: [leaderID], code: randomInt)
            try await client.from(TableTypes.parties.tableName).upsert(party).execute()
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
}
