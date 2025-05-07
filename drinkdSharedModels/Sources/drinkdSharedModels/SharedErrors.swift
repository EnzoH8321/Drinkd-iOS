//
//  File.swift
//  drinkdVaporServer
//
//  Created by Enzo Herrera on 5/4/25.
//

import Foundation

public enum SharedErrors: Error, Codable {

    case supabase(SupaBase)
    case internalServerError(String)

    public enum SupaBase: Error, Codable {

        case missingValue(String)
        case castingError(String)
        case invalidPartyCode
        case partyLeaderCannotJoinAParty
        case userIsAlreadyInAParty
       
    }



}

// Converts Errors -> Codable
// Error -> String

public struct ErrorWrapper: Codable {
    public let error: SharedErrors

    public init(errorType: some Error) {

        if let error = errorType as? SharedErrors.SupaBase {
            switch error {
            case .missingValue(let string):
                self.error = .supabase(.missingValue(string))
            case .castingError(let string):
                self.error = .supabase(.castingError(string))
            case .invalidPartyCode:
                self.error = .supabase(.invalidPartyCode)
            case .partyLeaderCannotJoinAParty:
                self.error = .supabase(.partyLeaderCannotJoinAParty)
            case .userIsAlreadyInAParty:
                self.error = .supabase(.userIsAlreadyInAParty)
            }

        } else {
            self.error = .internalServerError(errorType.localizedDescription)
        }


    }
}

