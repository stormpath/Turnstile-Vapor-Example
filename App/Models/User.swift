
import Fluent

final class User: Model {
    var id: Value?
    var username: String
    var passwordHash: String
    
    init(serialized: [String: Value]) {
        // Should figure out the optional Model initializer?
        username = serialized["name"]?.string ?? ""
        passwordHash = serialized["passwordHash"]?.string ?? ""
    }
}
