//
//  File.swift
//  drinkdVaporServer
//
//  Created by Enzo Herrera on 5/4/25.
//

import Foundation

public enum Errors: Error {

    public enum SupaBase: Error {

        public enum Networking: Error {

        }
        
        public enum Data: Error {
            case castingError
        }

    }

}
