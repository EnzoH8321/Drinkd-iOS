import Vapor
import drinkdSharedModels

func routes(_ app: Application) throws {

    let supabase = SupaBase()

    app.get { req async in
        "It works!"
    }

    app.get("test") { req async -> String in
        return "Hello, world!"
    }
}
