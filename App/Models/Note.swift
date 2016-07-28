import Fluent

class Note: Model {
    var id: Value?
    var userId: Int
    var note: String
    
    required init(serialized: [String: Value]) {
        // Should figure out the optional Model initializer?
        userId = (serialized["userId"]?.int) ?? 0
        note = serialized["note"]?.string ?? ""
    }
    
    init(userId: Int, note: String) {
        self.userId = userId
        self.note = note
    }
}
