import Vapor
import drinkdSharedModels

func routes(_ app: Application, supabase: SupaBase) throws {

    // If successful, return a party ID
    // If unsuccessful, return an error string
    app.post("createParty") { req async -> Response in
        do {
            guard let reqBody = req.body.data else { return Response(status: .badRequest) }
            let partyRequest = try JSONDecoder().decode(CreatePartyRequest.self, from: reqBody)
            
            let newParty = try await supabase.createAParty(partyRequest)

            guard let partyID = newParty.id else { throw SharedErrors.General.missingValue("Missing id value")}
            let response = Response()
            response.headers.add(name: "Content-Type", value: "application/json")
            let routeResponseObject = RouteResponse(currentUserName: partyRequest.username, currentUserID: partyRequest.userID, currentPartyID: partyID)
            let encodedResponse = try JSONEncoder().encode(routeResponseObject)

            response.body = Response.Body(data: encodedResponse)

            // Create a message channel
            await supabase.rdbCreateChannel(partyID: partyID)

            return response
        } catch {
            Log.routes.warning("Error on createParty route - \(error)")
            return createErrorResponse(error: error)
        }

    }

    // Join Party
    app.post("joinParty") { req async -> Response in

        do {
            guard let reqBody = req.body.data else { return Response(status: .badRequest) }
            let partyRequest = try JSONDecoder().decode(JoinPartyRequest.self, from: reqBody)
            let (party, user) = try await supabase.joinParty(partyRequest)

            guard let partyID = party.id else { throw SharedErrors.General.missingValue("Missing id value")}

            let routeResponseObject = RouteResponse(currentUserName: user.username, currentUserID: user.id, currentPartyID: partyID)
            let responseJSON = try JSONEncoder().encode(routeResponseObject)

            let response = Response()
            response.body = Response.Body(data: responseJSON)

            return response

        } catch {
            Log.routes.warning("Error on joinParty route - \(error)")
            return createErrorResponse(error: error)
        }
    }

    // Leave Party
    app.post("leaveParty") { req async -> Response in

        do {
            guard let reqBody = req.body.data else { return Response(status: .badRequest) }
            let partyRequest = try JSONDecoder().decode(LeavePartyRequest.self, from: reqBody)

            guard let userData = try await supabase.fetchRow(tableType: .users, dictionary: ["id": "\(partyRequest.userID)"]).first as? UsersTable else {
                throw SharedErrors.supabase(error: .rowIsEmpty)
            }
            guard let partyData = try await supabase.fetchRow(tableType: .parties, dictionary: ["party_leader": "\(partyRequest.userID)"]).first as? PartiesTable else {
                throw SharedErrors.supabase(error: .rowIsEmpty)
            }

            guard let partyID = partyData.id else { throw SharedErrors.General.missingValue("Missing id value")}

            try await supabase.leaveParty(partyRequest, partyID: partyID)

            let routeResponseObject = RouteResponse(currentUserName: userData.username, currentUserID: userData.id, currentPartyID: partyID)
            let responseJSON = try JSONEncoder().encode(routeResponseObject)

            let response = Response()
            response.body = Response.Body(data: responseJSON)

            return response

        } catch {
            Log.routes.warning("Error on leaveParty route - \(error)")
            return createErrorResponse(error: error)
        }

    }

    // Send Message
    app.post("sendMessage") { req async -> Response in

        do {
            guard let reqBody = req.body.data else { return Response(status: .badRequest) }
            let msgReq = try JSONDecoder().decode(SendMessageRequest.self, from: reqBody)

            guard let userData = try await supabase.fetchRow(tableType: .users, dictionary: ["id": "\(msgReq.userID)"]).first as? UsersTable else {
                throw SharedErrors.supabase(error: .rowIsEmpty)
            }

            let routeResponseObject = RouteResponse(currentUserName: userData.username, currentUserID: userData.id, currentPartyID: msgReq.partyID)
            let responseJSON = try JSONEncoder().encode(routeResponseObject)

            try await supabase.sendMessage(msgReq)

            let response = Response()
            response.body = Response.Body(data: responseJSON)

            // Broadcast message
            await supabase.rdbSendMessage(msgReq.message, partyID: msgReq.partyID)

            return response
        } catch {
            Log.routes.warning("Error on leaveParty route - \(error)")
            return createErrorResponse(error: error)
        }

    }

    // Update Rating
    app.post("updateRating") { req async -> Response in

        do {
            guard let reqBody = req.body.data else { return Response(status: .badRequest) }
            let msgReq = try JSONDecoder().decode(UpdateRatingRequest.self, from: reqBody)

            try await supabase.updateRestaurantRating(msgReq)

            let routeResponseObj = RouteResponse(currentUserName: msgReq.userName, currentUserID: msgReq.userID, currentPartyID: msgReq.partyID)
            let responseJSON = try JSONEncoder().encode(routeResponseObj)

            let response = Response()
            response.body = Response.Body(data: responseJSON)

            return response

        } catch {
            Log.routes.warning("Error on updateRating route - \(error)")
            return createErrorResponse(error: error)
        }
    }

    // MARK: WebSocket
    app.webSocket("testWS", ":username",":partyID") { req, ws in

        guard let partyID = req.parameters.get("partyID") else {
            Log.routes.fault("Party ID not found")
            return
        }

        guard let username = req.parameters.get("username") else {
            Log.routes.fault("Username not found")
            return
        }

        // Check if the websocket connection has closed
        ws.onClose.whenComplete { result in
            switch result {
            case .success(let success):
                Log.routes.debug("Successfully closed websocket connection for PARTYID: \(partyID)")
            case .failure(let failure):
                Log.routes.fault("Unable to close websocket connection - \(failure)")
            }
        }

//        if let closeWS = req.parameters.get("closeWS") {
//            if closeWS == "CloseWS" {
//                Task {
//                    try await ws.close()
//                }
//            }
//        }

        // Get Channel
        guard let channel = supabase.channels[partyID] else {
            Log.routes.fault("Channel not found")
            return
        }

        // Get Broadcast stream
        let stream = channel.broadcastStream(event: "newMessage")
        var messageArray: [String] = []

        Task {

            // Get latest Messages
            for await jsonObj in stream {

                guard let payload = jsonObj["payload"]?.value as? [String: Any] else {
                    Log.routes.fault("Unable to parse payload")
                    return
                }

                guard let message = payload["message"] as? String else {
                    Log.routes.fault("Unable to parse message")
                    return
                }

                messageArray.append("This message - \(message)")

                let timestamp = Date.now

                do {
                    let wsMessage = WSMessage(text: message, username: username, timestamp: timestamp)
                    let data = try JSONEncoder().encode(wsMessage)
                    let byteArray: [UInt8] = data.withUnsafeBytes { bytes in
                        return Array(bytes)
                    }

                    try await ws.send(byteArray)
                } catch {
                    Log.routes.fault("Error sending ws message - \(message)")
                }

            }
            
            Log.routes.info("TASK DONE")
        }

    }


}

fileprivate func createErrorResponse(error: any Error) -> Response {
    let errorWrapperJSON = try! JSONEncoder().encode(ErrorWrapper(errorType: error))
    let errorResponse = Response()
    errorResponse.status = .internalServerError
    errorResponse.headers.add(name: "Content-Type", value: "application/json")
    errorResponse.body = Response.Body(data: errorWrapperJSON)

    return errorResponse
}
