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
                    let req = try JSONDecoder().decode(CreatePartyRequest.self, from: reqBody)

                    let newParty = try await supabase.createAParty(req)

                    // Create a message channel
                    await supabase.rdbCreateChannel(partyID: newParty.id)

                    let respObj = CreatePartyResponse(partyID: newParty.id, partyCode: newParty.code)
                    return try RouteHelper.createResponse(data: respObj)

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
                    let req = try JSONDecoder().decode(JoinPartyRequest.self, from: reqBody)
                    let party = try await supabase.joinParty(req)

                    let respObj = JoinPartyResponse(partyID: party.id, partyName: party.party_name, partyCode: party.code, yelpURL: party.restaurants_url ?? "")
                    return try RouteHelper.createResponse(data: respObj)

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

                    let req = try JSONDecoder().decode(LeavePartyRequest.self, from: reqBody)

                    let partyData = try await supabase.fetchRows(tableType: .parties, dictionary: ["party_leader": "\(req.userID)"]).first as? PartiesTable

                    // Check if party leader
                    let partyRow = try await supabase.fetchRows(tableType: .parties, dictionary: ["party_leader": req.userID])

                    if !partyRow.isEmpty {
                        guard let partyData else { throw SharedErrors.supabase(error: .rowIsEmpty) }
                        try await supabase.leavePartyAsHost(req, partyID: partyData.id)
                    } else {
                        try await supabase.leavePartyAsGuest(req)
                    }

                    return Response()

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

                    // Send Message
                    try await supabase.sendMessage(msgReq)

                    // Broadcast message
                    await supabase.rdbSendMessage(userName: msgReq.userName, message: msgReq.message, partyID: msgReq.partyID)

                    return Response()
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

                    return Response()

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

                    let responseObj = TopRestaurantsGetResponse(restaurants: topRestaurants)

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
                    let userTable = try await supabase.fetchRows(tableType: .users, dictionary: ["id": userID]).first as? UsersTable
                    guard let userTable else { throw SharedErrors.general(error: .missingValue("UsersTable is nil"))}

                    let responseObj = RejoinPartyGetResponse(username: userTable.username, partyID: party.id, partyCode: party.code, yelpURL: party.restaurants_url ?? "", partyName: party.party_name)

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

                guard let username = payload["userName"] as? String else {
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
