//
//  File.swift
//  drinkdVaporServer
//
//  Created by Enzo Herrera on 5/12/25.
//

import Foundation
import Vapor

final class RouteHelper {

    static func createResponse<T: Encodable>(data: T) throws -> Response {
        let data = try JSONEncoder().encode(data)
        let response = Response()
        response.body = Response.Body(data: data)
        return response
    }

}
