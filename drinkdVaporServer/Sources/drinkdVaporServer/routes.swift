import Vapor

func routes(_ app: Application) throws {

    let supabase = SupaBase()

app.get { req async in
        "It works!"
    }

    app.get("test") { req async -> String in
        await supabase.readDataFromTable(tableType: .parties)
       return "Hello, world!"
    }
}
