//
//  Constants.swift
//  drinkdVaporServer
//
//  Created by Enzo Herrera on 5/1/25.
//

import Foundation
import Supabase
import drinkdSharedModels
import WebSocketKit
import Vapor

// Add this custom storage class
class VaporAuthStorage: AuthLocalStorage, @unchecked Sendable {
    private var storage: [String: Data] = [:]

    func store(key: String, value: Data) {
        storage[key] = value
    }

    func retrieve(key: String) -> Data? {
        return storage[key]
    }

    func remove(key: String) {
        storage.removeValue(forKey: key)
    }
}

final class SupaBase {
    // RDB Channels
    // [channel name: channel]
    var channels: [String: RealtimeChannelV2] = [:]
    private let client: SupabaseClient

    init() {
        let supabaseKey: String

        // Try to read Supabase key from Docker secret first
//        if let secretKey = try? String(contentsOfFile: "/run/secrets/supabase_key").trimmingCharacters(in: .whitespacesAndNewlines) {
//            supabaseKey = secretKey
//        }
        // Fallback to environment variable
        if let envKey = Environment.get("SUPABASE_KEY") {
            supabaseKey = envKey
        }
        else {
            fatalError("SUPABASE_KEY not found in secrets or environment variables")
        }

        // Get Supabase URL from environment variable
        //        guard let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"],
        //              let url = URL(string: urlString) else {
        //            fatalError("SUPABASE_URL environment variable is required and must be a valid URL")
        //        }
        guard let supabaseURL = URL(string: "https://jdkdtahoqpsspesqyojb.supabase.co") else {
            fatalError("Invalid Supabase URL")
        }

        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                db: .init(),
                auth: .init(storage: VaporAuthStorage()),
                global: .init(),
                realtime: .init()
            )
        )
    }

//    init() {
//           let supabaseKey: String
//
//           // Try to read from Docker secret first
//           if let secretKey = try? String(contentsOfFile: "/run/secrets/supabase_key").trimmingCharacters(in: .whitespacesAndNewlines) {
//               supabaseKey = secretKey
//           }
//           // Fallback to environment variable
//           else if let envKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] {
//               supabaseKey = envKey
//           }
//           else {
//               fatalError("SUPABASE_KEY not found in secrets or environment variables")
//           }
//
//           guard let supabaseURL = URL(string: "https://jdkdtahoqpsspesqyojb.supabase.co") else {
//               fatalError("Invalid Supabase URL")
//           }
//
//           self.client = SupabaseClient(
//               supabaseURL: supabaseURL,
//               supabaseKey: supabaseKey,
//               options: SupabaseClientOptions(
//                   db: .init(),
//                   auth: .init(storage: VaporAuthStorage()),
//                   global: .init(),
//                   realtime: .init()
//               )
//           )
//       }

//    private let client = SupabaseClient(
//        supabaseURL: URL(string: "https://jdkdtahoqpsspesqyojb.supabase.co")!,
//        supabaseKey: ProcessInfo.processInfo.environment["SUPABASE_KEY"]!,
//        options: SupabaseClientOptions(
//            db: .init(),
//            auth: .init( storage: VaporAuthStorage()),
//            global: .init(),
//            realtime: .init(),
//        )
//    )
    

    // Manually deletes the party.
    // Only the party leader should be able to do this.
    private func deleteParty(userID: UUID, partyID: UUID) async throws {

        do {
            // Check if the party still exists in the parties table & if the person deleting is the party leader
            let isPartyLeader = try await fetchRows(tableType: .parties, dictionary: ["party_leader": userID]).isEmpty ? false : true

            // Happy Path, delete the party
            if isPartyLeader { try await deleteRow(fromTable: .parties, rowID: partyID, userID: userID) }

        } catch {
            Log.supabase.error("Unable to Delete Party due to error: \(error)")
            throw error
        }
    }

    // Upsert a row to a table
    // Upsert inserts a new row if one does not exist, otherwise update it
    private func upsertDataToTable<T: SupaBaseTable & Encodable >(tableType: TableTypes, data: T) async throws {

        do {
            let table = try tableType.typeCast(from: data)
            try await client.from(tableType.tableName).upsert(table).execute()
        } catch {
            Log.supabase.error("upsertDataToTable failed: \(error)")
            throw error
        }

    }

    // Insert a row to a table
    private func insertRowToTable<T: SupaBaseTable>(tableType: TableTypes, data: T) async throws {

        do {
            let table = try tableType.typeCast(from: data)
            try await client.from(tableType.tableName).insert(table).execute()

        } catch {
            Log.supabase.error("insertRowToTable failed: \(error)")
            throw error
        }

    }

    // Delete a row in a table
    private func deleteRow(fromTable: TableTypes, rowID: UUID, userID: UUID? = nil) async throws {

        switch fromTable {
        case .parties:

            guard let userID = userID else {
                Log.supabase.error("Invalid Leader ID passed in")
                throw SharedErrors.supabase(error: .dataNotFound)
            }

            do {
                try await client.from(fromTable.tableName).delete().eq("party_leader", value: userID).execute()
            } catch {
                Log.supabase.error("deleteDataFromTable failed: \(error)")
                throw error
            }

        case .users, .messages,.ratedRestaurants:
            do {
                try await client.from(fromTable.tableName).delete().eq("id", value: rowID).execute()
            } catch {
                Log.supabase.error("deleteDataFromTable failed: \(error)")
                throw error
            }
        }
    }

    func fetchRows(tableType: TableTypes, dictionary: [String: any PostgrestFilterValue] = [:]) async throws -> [any SupaBaseTable] {

        let response = try await client
            .from(tableType.tableName)
            .select()
            .match(dictionary)
            .execute()

        do {
            return try tableType.decode(from: response.data)
        } catch {
            Log.supabase.error("fetchRow failed: \(error)")
            throw error
        }
    }

}

//MARK: Routes Calls
extension SupaBase {

    /// Creates a Party
    func createAParty(_ req: CreatePartyRequest) async throws -> PartiesTable {

        // Check that user is not already a party leader
        let isMemberOfAnotherParty = try await fetchRows(tableType: .parties, dictionary: ["party_leader": "\(req.userID)"]).count > 0

        if isMemberOfAnotherParty {
            throw SharedErrors.supabase(error: .userIsAlreadyAPartyLeader)
        }

        // Add to Parties Table
        let randomInt = Int.random(in: 100000..<999999)
        let partyID = UUID()
        let party = PartiesTable(id: partyID, party_name: req.partyName, party_leader: req.userID, date_created: Date().ISO8601Format(), code: randomInt, restaurants_url: req.restaurants_url)
        // Add to Party Members Table
        try await client.from(TableTypes.parties.tableName).upsert(party).execute()

        // Add to Users Table
        let user = UsersTable(id: req.userID, username: req.username, date_created: Date().ISO8601Format(), memberOfParty: partyID)
        try await client.from(TableTypes.users.tableName).upsert(user).execute()


        return party
    }

    // Leave a party
    func leavePartyAsHost(_ req: LeavePartyRequest, partyID: UUID) async throws {
        // Delete Party
        try await deleteParty(userID: req.userID, partyID: partyID)
        // Delete User
        // For users, the row id is the user id
        try await deleteRow(fromTable: .users, rowID: req.userID)
    }

    func leavePartyAsGuest(_ req: LeavePartyRequest) async throws {
        try await deleteRow(fromTable: .users, rowID: req.userID)
    }

    // Join a Party
    // Only works if you are not party leader, a party leader cannot join a party
    // Party Code should be six digits.
    // User should not be in another party
    func joinParty(_ req: JoinPartyRequest) async throws ->  PartiesTable {

        // Check that party code is six digits
        if req.partyCode < 100000 || req.partyCode > 999999 {
            throw SharedErrors.SupaBase.invalidPartyCode
        }

        // Find party using the party code
        guard let row = try await fetchRows(tableType: .parties, dictionary: ["code": req.partyCode]) as? [PartiesTable] else {
            throw SharedErrors.General.castingError("Unable to cast row as parties table")
        }

        guard let partyTable = row.first else {
            throw SharedErrors.supabase(error: .rowIsEmpty)
        }

        // Happy Path, party exists with that code, get party ID
        let newUser = UsersTable(id: req.userID, username: req.username, date_created: Date().ISO8601Format(), memberOfParty: partyTable.id)
        // Add to users table. This user will have a foreign key that traces back to the party
        try await upsertDataToTable(tableType: .users, data: newUser)

        return partyTable
    }

    // Update Restaurant rating
    func updateRestaurantRating(_ req: UpdateRatingRequest) async throws {

        // Check if the user already rated this restaurant
        let existingRestaurant = try await self.fetchRows(tableType: .ratedRestaurants, dictionary: ["user_id": req.userID, "restaurant_name": req.restaurantName]).first as? RatedRestaurantsTable

        let id = existingRestaurant != nil ? existingRestaurant!.id : UUID()
        let restaurant = RatedRestaurantsTable(id: id ,partyID: req.partyID, userID: req.userID, userName: req.userName, restaurantName: req.restaurantName, rating: req.rating, imageURL: req.imageURL)

        try await upsertDataToTable(tableType: .ratedRestaurants, data: restaurant)
    }

    func sendMessage(_ req: SendMessageRequest, messageID: UUID) async throws {

        let message = MessagesTable(id: messageID, partyId: req.partyID, date_created: Date().ISO8601Format(), text: req.message, userId: req.userID, user_name: req.userName)
        // Add message to messages table
        try await upsertDataToTable(tableType: .messages, data: message)

    }

    // Gets an array of the Top three choices.
    func getTopChoices(partyID: String) async throws -> [RatedRestaurantsTable] {
        var sorted: [RatedRestaurantsTable] = []

        guard let restaurants = try await fetchRows(tableType: .ratedRestaurants, dictionary: ["party_id": partyID]) as? [RatedRestaurantsTable] else {
            throw SharedErrors.supabase(error: .dataNotFound)
        }

        if restaurants.isEmpty {
            Log.supabase.info("Empty restaurants array")
            return []
        }


      // Loop through restaurants, adding them to the dict.
        for restaurant in restaurants {

            guard let existingIndex = sorted.firstIndex(where: { $0.id == restaurant.id }) else {
                // If the restaurant doesn't exist, add it
                //                restaurantDict[restaurant] = restaurant.rating
                sorted.append(restaurant)
                continue
            }

            // Here if the restaurant already exists
            // Sums up the ratings
            sorted[existingIndex].rating += restaurant.rating
        }

        // Sort by score & restaurant name
        sorted = sorted.sorted {
            if $0.rating == $1.rating {
                return $0.restaurant_name > $1.restaurant_name  // Secondary sort
            }
            return $0.rating > $1.rating  // Primary sort
        }

        // Remove everything after third place if there are more than 3 restaurants
        // TODO: Deal with ties. There could be multiple first second etc.
        if sorted.count > 3 {
            sorted.removeSubrange(3...)
        }


        return sorted
    }

    func rejoinParty(userID: String) async throws -> PartiesTable {
        // Query the Users Table and get the associated party_id of the user
        guard let user = try await fetchRows(tableType: .users, dictionary: ["id": userID]).first as? UsersTable else { throw SharedErrors.supabase(error: .dataNotFound)}
        // Get party ID of the user
        let partyID = user.party_id

        // Query the Parties Table and get the associated PartiesTable
        guard let party = try await fetchRows(tableType: .parties, dictionary: ["id": partyID]).first as? PartiesTable else { throw SharedErrors.supabase(error: .dataNotFound)}

        return party

    }
}

//MARK: RealTime DB
extension SupaBase {
    // Creates channel, partyID should be the channel identifier
    // Only use when creating party
    func rdbCreateChannel(partyID: UUID) async {

        let channel = client.channel(partyID.uuidString) {
            $0.broadcast.receiveOwnBroadcasts = true
        }

        let broadcastStream = channel.broadcastStream(event: "newMessage")

        await channel.subscribe()

        channels[partyID.uuidString] = channel
    }

    func rdbSendMessage(userName: String, userID: UUID, message: String, messageID: UUID, partyID: UUID) async {

        if let channel = channels[partyID.uuidString] {

            do {

                try await channel.broadcast(
                    event: "newMessage",
                    message: [
                        "message": message,
                        "userID": userID.uuidString,
                        "userName": userName,
                        "messageID": messageID.uuidString
                    ]
                )

            } catch {
                Log.supabase.error("Error in rdbSendMessage - \(error)")
            }

        }
    }


    func rdbListenForMessages(ws: WebSocket, partyID: String) {

        // Get Channel
        guard let channel = channels[partyID] else {
            Log.routes.error("Channel not found")
            return
        }

        // Get Broadcast stream
        let stream = channel.broadcastStream(event: "newMessage")

        Task {
            // Get latest Messages
            for await jsonObj in stream {

                guard let payload = jsonObj["payload"]?.value as? [String: Any] else {
                    Log.routes.error("Unable to parse payload")
                    return
                }

                guard let message = payload["message"] as? String else {
                    Log.routes.error("Unable to parse message")
                    return
                }

                guard let username = payload["userName"] as? String else {
                    Log.routes.error("Unable to parse username")
                    return
                }

                guard let idString = payload["messageID"] as? String, let messageID = UUID(uuidString: idString)  else {
                    Log.routes.error("Unable to parse messageID")
                    return
                }

                guard let userIDString = payload["userID"] as? String, let userID = UUID(uuidString: userIDString)  else {
                    Log.routes.error("Unable to parse userID")
                    return
                }

                do {
                    let wsMessage = WSMessage(id: messageID, text: message, username: username, timestamp: Date.now, userID: userID)
                    let data = try JSONEncoder().encode(wsMessage)
                    let byteArray: [UInt8] = data.withUnsafeBytes { bytes in
                        return Array(bytes)
                    }

                    try await ws.send(byteArray)
                } catch {
                    Log.routes.error("Error sending ws message - \(message)")
                }

            }

            Log.routes.info("TASK DONE")
        }
    }


}


