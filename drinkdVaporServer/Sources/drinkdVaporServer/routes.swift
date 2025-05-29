import Vapor
import drinkdSharedModels

func routes(_ app: Application, supabase: SupaBase) throws {

    // If successful, return a party ID
    // If unsuccessful, return an error string
    app.post("createParty") { req async -> Response in
        do {
            guard let reqBody = req.body.data else { return Response(status: .badRequest) }
            let partyRequest = try JSONDecoder().decode(CreatePartyRequest.self, from: reqBody)
            
            let newParty = try await supabase.createAParty(leaderID: partyRequest.userID, userName: partyRequest.username)

            guard let partyID = newParty.id else { throw SharedErrors.General.missingValue("Missing id value")}
            let response = Response()
            response.headers.add(name: "Content-Type", value: "application/json")
            let routeResponseObject = RouteResponse(currentUserName: partyRequest.username, currentUserID: partyRequest.userID, currentPartyID: partyID)
            let encodedResponse = try JSONEncoder().encode(routeResponseObject)

            response.body = Response.Body(data: encodedResponse)

            // Create a message channel
            await supabase.rdbCreateChannel(partyID: partyID)

            // Create web socket
            await createWebSocket(app: app, partyID: partyID, supabase: supabase)

            return response
        } catch {
            return createErrorResponse(error: error)
        }


    }

    // Join Party
    app.post("joinParty") { req async -> Response in

        do {
            guard let reqBody = req.body.data else { return Response(status: .badRequest) }
            let partyRequest = try JSONDecoder().decode(JoinPartyRequest.self, from: reqBody)
            let (party, user) = try await supabase.joinParty(username: partyRequest.username, partyCode: partyRequest.partyCode)

            guard let partyID = party.id else { throw SharedErrors.General.missingValue("Missing id value")}

            let routeResponseObject = RouteResponse(currentUserName: user.username, currentUserID: user.id, currentPartyID: partyID)
            let responseJSON = try JSONEncoder().encode(routeResponseObject)

            let response = Response()
            response.body = Response.Body(data: responseJSON)

            return response

        } catch {
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

            try await supabase.leaveParty(userID: partyRequest.userID, partyID: partyID)

            let routeResponseObject = RouteResponse(currentUserName: userData.username, currentUserID: userData.id, currentPartyID: partyID)
            let responseJSON = try JSONEncoder().encode(routeResponseObject)

            let response = Response()
            response.body = Response.Body(data: responseJSON)

            return response

        } catch {
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

            try await supabase.sendMessage(userID: msgReq.userID, partyID: msgReq.partyID, text: msgReq.message)

            let response = Response()
            response.body = Response.Body(data: responseJSON)

            // Broadcast message
            await supabase.rdbSendMessage(msgReq.message, partyID: msgReq.partyID)

            return response
        } catch {
            return createErrorResponse(error: error)
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

fileprivate func createWebSocket(app: Application, partyID: UUID, supabase: SupaBase) async {
    // route should be ws_partyID
    // ex ws_34534dfgdf

    let route = "testWS"
    let channel = supabase.channels[partyID.uuidString]

    if let validChannel = channel {
        let messages = await supabase.rdbReadMessage(channel: validChannel.broadcastStream(event: "newMessage"))
        
        guard let lastMessage = messages.last else {
            print("NO LAST MESSAGE")
            return
        }

        app.webSocket("\(route)") { req, ws in
            print(ws)
            ws.send(lastMessage)
        }

    } else {
        print("INVALID CHANNEL")
    }



}
