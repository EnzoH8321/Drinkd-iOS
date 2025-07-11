//
//  File.swift
//  drinkdVaporServer
//
//  Created by Enzo Herrera on 5/4/25.
//

import Foundation

public enum SharedErrors: Codable, LocalizedError {

    case supabase(error: SupaBase)
    case general(error: General)
    case yelp(error: Yelp)
    case internalServerError(error: String)


    public enum SupaBase: String, LocalizedError, Codable {

        case invalidPartyCode
        case partyLeaderCannotJoinAParty
        case userIsAlreadyInAParty
        case userIsAlreadyAPartyLeader
        case rowIsEmpty
        case dataNotFound

        public var errorDescription: String? {
            return self.rawValue
        }

    }

    public enum General: LocalizedError, Codable {
        case missingValue(String)
        case castingError(String)
        case userDefaultsError(String)
        case generalError(String)


        public var errorDescription: String? {
            switch self {
            case .missingValue(let string):
                return "missingValue error - \(string)"
            case .castingError(let string):
                return "casting error - \(string)"
            case .userDefaultsError(let string):
                return "userDefaultsError - \(string)"
            case .generalError(let string):
                return "general error - \(string)"
            }
        }

    }

    public enum Yelp: LocalizedError, Codable {
        case missingProperty(String)

        public var errorDescription: String? {
            switch self {
            case .missingProperty(let string):
                return "missingProperty error - \(string)"
            }
        }
    }

    public var errorDescription: String? {
        switch self {
        case .supabase(let error):
            return error.localizedDescription
        case .general(let error):
            return error.localizedDescription
        case .internalServerError(let error):
            return error
        case .yelp(error: let error):
            return error.localizedDescription
        }


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
            case .userIsAlreadyAPartyLeader:
                self.error = .supabase(error: .userIsAlreadyAPartyLeader)
            }

        case let errorType as SharedErrors.General:

            switch errorType {

            case .missingValue(let string):
                self.error = .general(error: .missingValue(string))
            case .castingError(let string):
                self.error = .general(error: .castingError(string))
            case .userDefaultsError(let string):
                self.error = .general(error: .userDefaultsError(string))
            case .generalError(let string):
                self.error = .general(error: .userDefaultsError(string))
            }

        default:
            self.error = .internalServerError(error: errorType.localizedDescription)
        }

    }
}

