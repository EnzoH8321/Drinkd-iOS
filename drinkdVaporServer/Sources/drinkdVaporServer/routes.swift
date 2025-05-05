import Vapor
import drinkdSharedModels

func routes(_ app: Application) throws {

    let supabase = SupaBase()

    app.get { req async in
        "It works!"
    }

    app.get("test") { req async -> String in
       await supabase.manuallyDeleteParty(userID: UUID(uuidString: "4B18F13A-E8C6-4E6B-A187-25517F20D35D")!, partyID: UUID(uuidString: "5b04fdcf-3e83-468e-b933-b8aed5abee79")!)
       return "test"
    }
}
