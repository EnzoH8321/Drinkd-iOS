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

    /// Creates a Party
    func createAParty(leaderID: UUID, userName: String) async {
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
        }

    }

    func manuallyDeleteParty(leaderID: UUID, partyID: UUID) async {
        // Check if the party still exists in the parties table & if the person deleting is the party leader
        let parties = await getAllRecordsFromTable(tableType: .parties, dictionary: ["party_leader": leaderID])

        if parties.isEmpty {
            print("No Parties Found")
            return
        }

        if parties.count > 1 {
            print("Party Leader is the leader of muiltiple parties")
            return
        }

        // Happy Path
        await deleteDataFromTable(fromTable: .parties, partyID: partyID, partyLeader: leaderID)

    }

    // Dictionary represents filters. [column name: value to filter for]
    func getAllRecordsFromTable(tableType: TableTypes, dictionary: [String: any PostgrestFilterValue] = [:]) async -> [any SupaBaseTable] {

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

                return partiesArray

            case .users:
                let response = try await client
                    .from(tableType.tableName)
                    .select(dictionary.count == 0 ? "*" : columnsToFilterFor)
                    .match(dictionary)
                    .execute()

                let usersArray = try JSONDecoder().decode([UsersTable].self, from: Data(response.data))

                return usersArray
            }

        } catch {
            print("Error - \(error)")
            return []
        }

    }
    // Upsert a record to a table
    // Upsert inserts a new record if one does not exist, otherwise update it
     func upsertDataToTable<T: SupaBaseTable>(tableType: TableTypes, data: T) async {

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
        }

    }

    // Delete a record in a table
    func deleteDataFromTable(fromTable: TableTypes, partyID: UUID, partyLeader: UUID?) async {

        switch fromTable {
        case .parties:

            guard let validLeaderID = partyLeader else {
                print("Invalid Leader ID passed in")
                return
            }

            do {
                try await client.from(fromTable.tableName).delete().eq("party_leader", value: validLeaderID).execute()
            } catch {
                print("Error - \(error)")
            }

        case .users:
            do {
                try await client.from(fromTable.tableName).delete().eq("id", value: partyID).execute()
            } catch {
                print("Error - \(error)")
            }
        }


    }


}
