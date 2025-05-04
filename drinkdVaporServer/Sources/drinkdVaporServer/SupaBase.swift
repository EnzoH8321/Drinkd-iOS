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
    let client = SupabaseClient(
      supabaseURL: URL(string: "https://jdkdtahoqpsspesqyojb.supabase.co")!,
      supabaseKey: ProcessInfo.processInfo.environment["SUPABASE_KEY"]!
    )

    func insertData() async {
        let dateString = Date().ISO8601Format()
        let party = PartiesTable(id: UUID(), date_created: dateString, members: [], chat: UUID(), code: 345344)
        do {
         let test =    try await client
              .from("Parties")
              .insert(party)
              .execute()

            print("Success - \(test)")
        } catch {
            print("ERROR INSERTING DATA - \(error)")
        }
    }

    
}
