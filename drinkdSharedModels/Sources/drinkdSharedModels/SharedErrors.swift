//
//  File.swift
//  drinkdVaporServer
//
//  Created by Enzo Herrera on 5/4/25.
//

import Foundation

public enum SharedErrors: Error, Codable {

    case supabase(SupaBase)
    case general(General)
    case internalServerError(String)


    public enum SupaBase: Error, Codable {


        case invalidPartyCode
        case partyLeaderCannotJoinAParty
        case userIsAlreadyInAParty
       
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

        switch errorType {
        case let errorType as SharedErrors.SupaBase:

            switch errorType {

            case .invalidPartyCode:
                self.error = .supabase(.invalidPartyCode)
            case .partyLeaderCannotJoinAParty:
                self.error = .supabase(.partyLeaderCannotJoinAParty)
            case .userIsAlreadyInAParty:
                self.error = .supabase(.userIsAlreadyInAParty)
            }

        case let errorType as SharedErrors.General:

            switch errorType {

            case .missingValue(let string):
                self.error = .general(.missingValue(string))
            case .castingError(let string):
                self.error = .general(.castingError(string))
            }

        default:
            self.error = .internalServerError(errorType.localizedDescription)
        }

    }
}

