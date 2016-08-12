import Vapor
import Fluent

class Note: Model {

    var id: Node?
    var userId: Int
    var note: String
    
    required init(node: Node, in context: Context) throws {
        userId = try node.extract("user_id")
        note = try node.extract("note")
    }
    
    init(userId: Int, note: String) {
        self.userId = userId
        self.note = note
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": userId,
            "note": note
        ])
    }

    static func prepare(_ database: Database) throws {
        try database.create("notes") { notes in
            notes.id()
            notes.int("user_id")
            notes.string("note")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
    
    static func forUser(id: Node) throws -> Fluent.Query<Note> {
        return try self.query().filter("user_id", id)
    }
}
