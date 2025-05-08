import Vapor
import drinkdSharedModels

func routes(_ app: Application) throws {

    let supabase = SupaBase()
     let testUserID = UUID(uuidString: "4B18F13A-E8C6-4E6B-A187-25517F20D35D")!
     let testPartyID = UUID(uuidString: "5b04fdcf-3e83-468e-b933-b8aed5abee79")!

    app.get { req async in
        "It works!"
    }


    // If successful, return a party ID
    // If unsuccessful, return an error string
    app.post("createParty") { req async -> Response in
        do {
            guard let reqBody = req.body.data else { return Response(status: .badRequest) }
            let partyRequest = try JSONDecoder().decode(PartyRequest.self, from: reqBody)
            let leaderID = UUID()
            let newParty = try await supabase.createAParty(leaderID: leaderID, userName: partyRequest.username)

            guard let partyID = newParty.id?.uuidString else { throw SharedErrors.General.missingValue("Missing id value")}
            let response = Response()
            response.body = Response.Body(string: partyID)

            return response
        } catch {
            
            let errorResponse = Response()
            errorResponse.status = .internalServerError

            let errorWrapperJSON = try! JSONEncoder().encode(ErrorWrapper(errorType: error))

            errorResponse.body = Response.Body(data: errorWrapperJSON)
            return errorResponse
        }


    }

    // Join Party
    app.post("joinParty") { req async -> Response in

        do {
            guard let reqBody = req.body.data else { return Response(status: .badRequest) }
            let partyRequest = try JSONDecoder().decode(JoinPartyRequest.self, from: reqBody)
            let party = try await supabase.joinParty(username: partyRequest.username, partyCode: partyRequest.partyCode)

            guard let partyID = party.id?.uuidString else { throw SharedErrors.General.missingValue("Missing id value")}
            
            let response = Response()
            response.body = Response.Body(string: partyID)

            return response

        } catch {
            let errorWrapperJSON = try! JSONEncoder().encode(ErrorWrapper(errorType: error))
            let errorResponse = Response()
            errorResponse.status = .internalServerError
            errorResponse.headers.add(name: "Content-Type", value: "application/json")
            errorResponse.body = Response.Body(data: errorWrapperJSON)

            return errorResponse
        }

    }

}

