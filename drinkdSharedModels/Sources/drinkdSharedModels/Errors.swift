//
//  File.swift
//  drinkdVaporServer
//
//  Created by Enzo Herrera on 5/4/25.
//

import Foundation

public enum Errors: Error {

    public enum SupaBase: Error {

        case castingError(String)
        case invalidPartyCode
        case partyLeaderCannotJoinAParty
        case userIsAlreadyInAParty
    }

}
