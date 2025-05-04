import Vapor
import drinkdSharedModels

func routes(_ app: Application) throws {

    let supabase = SupaBase()

app.get { req async in
        "It works!"
    }

    app.get("test") { req async -> String in
//        await supabase.readDataFromTable(tableType: .parties)
        let party = PartiesTable(id: UUID(), date_created: Date().ISO8601Format(), members: [], chat: UUID(), code: 345344)

        await supabase.deleteDataFromTable(fromTable: .parties, id: UUID(uuidString: "30e3cdad-72f3-4c51-b30a-9399c6030a01")!)

       return "Hello, world!"
    }
}
