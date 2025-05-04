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

    func insertData() async {
        let dateString = Date().ISO8601Format()
        let party = PartiesTable(id: UUID(), date_created: dateString, members: [], chat: UUID(), code: 345344)
        do {
         let test =  try await client
              .from("Parties")
              .insert(party)
              .execute()
              .value

            print("Success - \(test)")
        } catch {
            print("ERROR INSERTING DATA - \(error)")
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
            }

        } catch {
            print("Error - \(error)")
        }

    }

    // Delete a record in a table
    func deleteDataFromTable(fromTable: TableTypes, id: UUID) async {

        do {
            switch fromTable {
            case .parties:
                try await client.from(fromTable.tableName).delete().eq("id", value: id).execute()
            }
        } catch {
            print("Error - \(error)")
        }
    }


}
