//
//  File.swift
//  drinkdVaporServer
//
//  Created by Enzo Herrera on 5/12/25.
//

import Foundation
import Vapor
import drinkdSharedModels

final class RouteHelper {

    static func createResponse<T: Encodable>(data: T) throws -> Response {
        let data = try JSONEncoder().encode(data)
        let response = Response()
        response.body = Response.Body(data: data)
        return response
    }

    static func createErrorResponse(error: any Error) -> Response {
        let errorWrapperJSON = try! JSONEncoder().encode(ErrorWrapper(errorType: error))
        let errorResponse = Response()
        errorResponse.status = .internalServerError
        errorResponse.headers.add(name: "Content-Type", value: "application/json")
        errorResponse.body = Response.Body(data: errorWrapperJSON)

        return errorResponse
    }

}
