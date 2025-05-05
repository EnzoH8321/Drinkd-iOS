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

     func readDataFromTable<T: SupaBaseTable>(tableType: TableTypes) async -> [T]? {

        do {
            switch tableType {

            case .parties:
                let response = try await client
                    .from(tableType.tableName)
                    .select()
                    .execute()

                guard let partiesArray = try? JSONDecoder().decode([PartiesTable].self, from: Data(response.data)) else { throw Errors.SupaBase.Data.decodingError }

                return partiesArray as? [T]

            case .users:
                let response = try await client
                    .from(tableType.tableName)
                    .select()
                    .execute()

                guard let usersArray = try? JSONDecoder().decode([UsersTable].self, from: Data(response.data)) else { throw Errors.SupaBase.Data.decodingError }

                return usersArray as? [T]
            }

        } catch {
            print("Error - \(error)")
            return nil
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
     func deleteDataFromTable(fromTable: TableTypes, id: UUID) async {

        do {
            try await client.from(fromTable.tableName).delete().eq("id", value: id).execute()
        } catch {
            print("Error - \(error)")
        }
    }


}
