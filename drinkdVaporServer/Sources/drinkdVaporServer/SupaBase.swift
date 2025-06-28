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
    // [channel name: channel]
    var channels: [String: RealtimeChannelV2] = [:]

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

            // Happy Path
            if matches { try await deleteDataFromTable(fromTable: .parties, rowID: partyID, userID: userID) }

        } catch {
            Log.supabase.fault("Unable to Delete Party due to error: \(error)")
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
                return try JSONDecoder().decode([PartiesTable].self, from: Data(response.data)).isEmpty ? false : true
            case .users:
                return try JSONDecoder().decode([UsersTable].self, from: Data(response.data)).isEmpty ? false : true
            case .messages:
                return try JSONDecoder().decode([MessagesTable].self, from: Data(response.data)).isEmpty ? false : true
            case .ratedRestaurants:
                return try JSONDecoder().decode([RatedRestaurantsTable].self, from: Data(response.data)).isEmpty ? false : true
            }

        } catch {
            Log.supabase.fault("checkMatching error: \(error)")
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

            case .ratedRestaurants:
                guard let restaurantData = data as? RatedRestaurantsTable else { throw SharedErrors.General.castingError("Unable to convert data to RatedRestaurantsTable")}

                try await client.from(tableType.tableName).upsert(restaurantData).execute()
            }
        } catch {
            Log.supabase.fault("upsertDataToTable failed: \(error)")
            throw error
        }

    }

    // Insert a row to a table
    private func insertRowToTable<T: SupaBaseTable>(tableType: TableTypes, data: T) async throws {

        do {
            switch tableType {
            case .parties:
                guard let partyData = data as? PartiesTable else { throw SharedErrors.General.castingError("Unable to convert data to PartiesTable") }

                try await client.from(tableType.tableName).insert(partyData).execute()
            case .users:
                guard let usersData = data as? UsersTable else { throw SharedErrors.General.castingError("Unable to convert data to UsersTable") }

                try await client.from(tableType.tableName).insert(usersData).execute()
            case .messages:
                guard let messagesData = data as? MessagesTable else { throw SharedErrors.General.castingError("Unable to convert data to MessagesTable")}

                try await client.from(tableType.tableName).insert(messagesData).execute()
            case .ratedRestaurants:
                guard let restaurantData = data as? RatedRestaurantsTable else { throw SharedErrors.General.castingError("Unable to convert data to MessagesTable")}
                try await client.from(tableType.tableName).insert(restaurantData).execute()
            }
        } catch {
            Log.supabase.fault("insertRowToTable failed: \(error)")
            throw error
        }

    }

    // Delete a row in a table
    private func deleteDataFromTable(fromTable: TableTypes, rowID: UUID, userID: UUID? = nil) async throws {

        switch fromTable {
        case .parties:

            guard let userID = userID else {
                Log.supabase.fault("Invalid Leader ID passed in")
                throw SharedErrors.supabase(error: .dataNotFound)
            }

            do {
                try await client.from(fromTable.tableName).delete().eq("party_leader", value: userID).execute()
            } catch {
                Log.supabase.fault("deleteDataFromTable failed: \(error)")
                throw error
            }

        case .users, .messages,.ratedRestaurants:
            do {
                try await client.from(fromTable.tableName).delete().eq("id", value: rowID).execute()
            } catch {
                Log.supabase.fault("deleteDataFromTable failed: \(error)")
                throw error
            }
        }
    }

    func fetchRows(tableType: TableTypes, dictionary: [String: any PostgrestFilterValue] = [:]) async throws -> [any SupaBaseTable] {
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
            case .ratedRestaurants:
                let restaurantsArray = try JSONDecoder().decode([RatedRestaurantsTable].self, from: Data(response.data))
                return restaurantsArray
            }

        } catch {
            Log.supabase.fault("fetchRow failed: \(error)")
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
        let party = PartiesTable(id: partyID, partyLeader: req.userID, date_created: Date().ISO8601Format(), code: randomInt)
        // Add to Party Members Table
        try await client.from(TableTypes.parties.tableName).upsert(party).execute()

        // Add to Users Table
        let user = UsersTable(id: req.userID, username: req.username, date_created: Date().ISO8601Format(), memberOfParty: partyID)
        try await client.from(TableTypes.users.tableName).upsert(user).execute()


        return party
    }

    // Leave a party
    func leaveParty(_ req: LeavePartyRequest, partyID: UUID) async throws {

        // Check if party leader
        let isPartyLeader = try await checkMatching(tableType: .parties, dictionary: ["party_leader": req.userID])

        // Path for leader
        if isPartyLeader {
            // Delete Party
            try await manuallyDeleteParty(userID: req.userID, partyID: partyID)
            // Delete User
            // For users, the row id is the user id
            try await deleteDataFromTable(fromTable: .users, rowID: req.userID)

        } else {
            // Path for Guest
            try await deleteDataFromTable(fromTable: .users, rowID: req.userID)

        }

    }

    // Join a Party
    // Only works if you are not party leader, a party leader cannot join a party
    // Party Code should be six digits.
    // User should not be in another party
    func joinParty(_ req: JoinPartyRequest) async throws -> (party: PartiesTable, user: UsersTable) {
        //        let user = UsersTable(id: UUID(), username: username, date_created: Date().ISO8601Format(), memberOfParty: nil)
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

        guard let validPartyID = partyTable.id else {
            throw SharedErrors.supabase(error: .dataNotFound)
        }


        // Happy Path, party exists with that code, get party ID
        let partyID = validPartyID
        let userID = UUID()
        let user = UsersTable(id: userID, username: req.username, date_created: Date().ISO8601Format(), memberOfParty: partyID)
        // Add to users table. This user will have a foreign key that traces back to the party
        try await upsertDataToTable(tableType: .users, data: user)

        return (partyTable, user)
    }

    // Update Restaurant rating
    func updateRestaurantRating(_ req: UpdateRatingRequest) async throws {

        // Check if the user already rated this restaurant
        let existingRestaurant = try await self.fetchRows(tableType: .ratedRestaurants, dictionary: ["user_id": req.userID, "restaurant_name": req.restaurantName]).first as? RatedRestaurantsTable

        let id = existingRestaurant != nil ? existingRestaurant!.id : UUID()
        let restaurant = RatedRestaurantsTable(id: id ,partyID: req.partyID, userID: req.userID, userName: req.userName, restaurantName: req.restaurantName, rating: req.rating)

        try await upsertDataToTable(tableType: .ratedRestaurants, data: restaurant)
    }

    func sendMessage(_ req: SendMessageRequest) async throws {

        let message = MessagesTable(id: UUID(), partyId: req.partyID, date_created: Date().ISO8601Format(), text: req.message, userId: req.userID)
        // Add message to messages table
        try await upsertDataToTable(tableType: .messages, data: message)

    }

    // Gets an array of the Top three choices.
    func getTopChoices(partyID: String) async throws -> [RatedRestaurantsTable] {
        var sorted: [RatedRestaurantsTable] = []

        guard let restaurants = try await fetchRows(tableType: .ratedRestaurants, dictionary: ["id": partyID]) as? [RatedRestaurantsTable] else {
            throw SharedErrors.supabase(error: .dataNotFound)
        }

        if restaurants.isEmpty {
            Log.general.info("Empty restaurants array")
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

        // Remove everything after third place
        // TODO: Deal with ties. There could be multiple first second etc.
        sorted.removeSubrange(3...)

        return sorted
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

    func rdbGetMessages(channel: AsyncStream<JSONObject>) async -> [String] {

        var messageArray: [String] = []

        Task {
            for await jsonObj in channel {

                guard let payload = jsonObj["payload"]?.value as? [String: Any] else {
                    print("Unable to parse payload")
                    return
                }

                guard let message = payload["message"] as? String else {
                    print("Unable to parse message")
                    return
                }

                messageArray.append("This message - \(message)")
            }
        }

        return messageArray
    }

    func rdbSendMessage(_ message: String, partyID: UUID) async {

        if let channel = channels[partyID.uuidString] {

            do {

                try await channel.broadcast(
                    event: "newMessage",
                    message: [
                        "message": message
                    ]
                )

            } catch {
                Log.supabase.fault("Error in rdbSendMessage - \(error)")
            }

        }
    }
}


