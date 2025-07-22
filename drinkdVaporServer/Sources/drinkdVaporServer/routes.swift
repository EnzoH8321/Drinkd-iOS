import Vapor
import drinkdSharedModels

func routes(_ app: Application, supabase: SupaBase) throws {

    // MARK: Post Routes
    for route in HTTP.PostRoutes.allCases {
        switch route {

        case .createParty:
            // If successful, return a party ID
            // If unsuccessful, return an error string
            app.post("createParty") { req async -> Response in
                do {
                    guard let reqBody = req.body.data else { return Response(status: .badRequest) }
                    let partyRequest = try JSONDecoder().decode(CreatePartyRequest.self, from: reqBody)

                    let newParty = try await supabase.createAParty(partyRequest)

                     let partyID = newParty.id
                    // Create a message channel
                    await supabase.rdbCreateChannel(partyID: partyID)

                    let routeResponseObject = PostRouteResponse(currentUserName: partyRequest.username, currentUserID: partyRequest.userID, currentPartyID: partyID, partyName: newParty.party_name, yelpURL: newParty.restaurants_url ?? "")
                    let response = try RouteHelper.createResponse(data: routeResponseObject)
                    response.headers.add(name: "Content-Type", value: "application/json")

                    return response
                } catch {
                    Log.routes.warning("Error on createParty route - \(error)")
                    return RouteHelper.createErrorResponse(error: error)
                }

            }

        case .joinParty:
            // Join Party
            app.post("joinParty") { req async -> Response in

                do {
                    guard let reqBody = req.body.data else { return Response(status: .badRequest) }
                    let partyRequest = try JSONDecoder().decode(JoinPartyRequest.self, from: reqBody)
                    let (party, user) = try await supabase.joinParty(partyRequest)

                    let routeResponseObject = PostRouteResponse(currentUserName: user.username, currentUserID: user.id, currentPartyID: party.id, partyName: party.party_name, yelpURL: party.restaurants_url ?? "")
                    return try RouteHelper.createResponse(data: routeResponseObject)

                } catch {
                    Log.routes.warning("Error on joinParty route - \(error)")
                    return RouteHelper.createErrorResponse(error: error)
                }
            }

        case .leaveParty:
            // Leave Party
            app.post("leaveParty") { req async -> Response in

                do {
                    guard let reqBody = req.body.data else { return Response(status: .badRequest) }

                    let partyRequest = try JSONDecoder().decode(LeavePartyRequest.self, from: reqBody)

                    let (userData, partyData) = try await (
                        supabase.fetchRows(tableType: .users, dictionary: ["id": "\(partyRequest.userID)"]).first as? UsersTable,
                        supabase.fetchRows(tableType: .parties, dictionary: ["party_leader": "\(partyRequest.userID)"]).first as? PartiesTable
                    )

                    guard let userData else { throw SharedErrors.supabase(error: .rowIsEmpty) }

                    // Check if party leader
                    let isPartyLeader = try await supabase.checkMatching(tableType: .parties, dictionary: ["party_leader": partyRequest.userID])

                    if isPartyLeader {
                        guard let partyData else { throw SharedErrors.supabase(error: .rowIsEmpty) }
                        try await supabase.leavePartyAsHost(partyRequest, partyID: partyData.id)
                    } else {
                        try await supabase.leavePartyAsGuest(partyRequest)
                    }


                    let routeResponseObject = PostRouteResponse(currentUserName: userData.username, currentUserID: userData.id, currentPartyID: UUID(), partyName: "", yelpURL: "")
                    return try RouteHelper.createResponse(data: routeResponseObject)

                } catch {
                    Log.routes.warning("Error on leaveParty route - \(error)")
                    return RouteHelper.createErrorResponse(error: error)
                }

            }

        case .sendMessage:
            // Send Message
            app.post("sendMessage") { req async -> Response in

                do {
                    guard let reqBody = req.body.data else { return Response(status: .badRequest) }
                    let msgReq = try JSONDecoder().decode(SendMessageRequest.self, from: reqBody)

                    guard let userData = try await supabase.fetchRows(tableType: .users, dictionary: ["id": "\(msgReq.userID)"]).first as? UsersTable else {
                        throw SharedErrors.supabase(error: .rowIsEmpty)
                    }

                    let routeResponseObject = PostRouteResponse(currentUserName: userData.username, currentUserID: userData.id, currentPartyID: msgReq.partyID, partyName: "", yelpURL: "")

                    // Send Message
                    try await supabase.sendMessage(msgReq)

                    // Broadcast message
                    await supabase.rdbSendMessage(msgReq.message, partyID: msgReq.partyID)

                    return try RouteHelper.createResponse(data: routeResponseObject)
                } catch {
                    Log.routes.warning("Error on leaveParty route - \(error)")
                    return RouteHelper.createErrorResponse(error: error)
                }

            }

        case .updateRating:
            // Update Rating
            app.post("updateRating") { req async -> Response in

                do {
                    guard let reqBody = req.body.data else { return Response(status: .badRequest) }
                    let msgReq = try JSONDecoder().decode(UpdateRatingRequest.self, from: reqBody)

                    try await supabase.updateRestaurantRating(msgReq)

                    let routeResponseObj = PostRouteResponse(currentUserName: msgReq.userName, currentUserID: msgReq.userID, currentPartyID: msgReq.partyID, partyName: "", yelpURL: "")

                    return try RouteHelper.createResponse(data: routeResponseObj)

                } catch {
                    Log.routes.warning("Error on updateRating route - \(error)")
                    return RouteHelper.createErrorResponse(error: error)
                }
            }

        }
    }

    //MARK: Get Route
    for route in HTTP.GetRoutes.allCases {
        switch route {

        case .topRestaurants:
            app.get("topRestaurants") { req async -> Response in

                do {
                    guard let path = req.url.query else { return Response(status: .badRequest) }
                    let pathComponents = path.components(separatedBy: "=")
                    guard let partyID = pathComponents.count == 2 ? pathComponents[1] : nil else { throw SharedErrors.general(error: .generalError("Unable to parse partyID"))}

                    let topRestaurants: [RatedRestaurantsTable] = try await supabase.getTopChoices(partyID: partyID)

                    let responseObj = GetRouteResponse(restaurants: topRestaurants, partyID: nil, partyName: nil, yelpURL: nil)

                    return try RouteHelper.createResponse(data: responseObj)
                } catch {
                    Log.routes.warning("Error on topChoices route - \(error)")
                    return RouteHelper.createErrorResponse(error: error)
                }

            }
        case .rejoinParty:
            app.get("rejoinParty") { req async -> Response in

                do {
                    guard let path = req.url.query else { return Response(status: .badRequest) }
                    let pathComponents = path.components(separatedBy: "=")
                    guard let userID = pathComponents.count == 2 ? pathComponents[1] : nil else { throw SharedErrors.general(error: .generalError("Unable to parse User ID"))}

                    // Get Party associated with the user
                    let party = try await supabase.rejoinParty(userID: userID)
                    
                    let responseObj = GetRouteResponse(restaurants: [], partyID: party.id, partyName: party.party_name, yelpURL: party.restaurants_url)

                    return try RouteHelper.createResponse(data: responseObj)

                } catch {
                    Log.routes.warning("Error on topChoices route - \(error)")
                    return RouteHelper.createErrorResponse(error: error)
                }
            }
        }
    }

    // MARK: WebSocket
    app.webSocket("testWS", ":username", ":userID", ":partyID", ) { req, ws in

        guard let partyID = req.parameters.get("partyID") else {
            Log.routes.fault("Party ID not found")
            return
        }

        guard let username = req.parameters.get("username") else {
            Log.routes.fault("Username not found")
            return
        }

        guard let userID =  UUID(uuidString: req.parameters.get("userID") ?? "")  else {
            Log.routes.fault("userID not found")
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
                    let wsMessage = WSMessage(text: message, username: username, timestamp: timestamp, userID: userID)
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
