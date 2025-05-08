//
//  File.swift
//  drinkdVaporServer
//
//  Created by Enzo Herrera on 5/4/25.
//

import Foundation

public enum SharedErrors: Error, Codable {

    case supabase(error: SupaBase)
    case general(error: General)
    case internalServerError(error: String)


    public enum SupaBase:  Error, Codable {

        case invalidPartyCode
        case partyLeaderCannotJoinAParty
        case userIsAlreadyInAParty
        case rowIsEmpty
        case dataNotFound
    }

    public enum General: Error, Codable {
        case missingValue(String)
        case castingError(String)
    }

}

// Converts Errors -> Codable
// Error -> String

public struct ErrorWrapper: Codable {
    public let error: SharedErrors

    public init(errorType: some Error) {
        print("‼️ ERROR - \(errorType)")
        switch errorType {
        case let errorType as SharedErrors.SupaBase:

            switch errorType {

            case .invalidPartyCode:
                self.error = .supabase(error: .invalidPartyCode)
            case .partyLeaderCannotJoinAParty:
                self.error = .supabase(error: .partyLeaderCannotJoinAParty)
            case .userIsAlreadyInAParty:
                self.error = .supabase(error: .userIsAlreadyInAParty)
            case .rowIsEmpty:
                self.error = .supabase(error: .rowIsEmpty)
            case .dataNotFound:
                self.error = .supabase(error: .dataNotFound)
            }

        case let errorType as SharedErrors.General:

            switch errorType {

            case .missingValue(let string):
                self.error = .general(error: .missingValue(string))
            case .castingError(let string):
                self.error = .general(error: .castingError(string))
            }

        default:
            self.error = .internalServerError(error: errorType.localizedDescription)
        }

    }
}

