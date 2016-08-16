import Turnstile
import TurnstileWeb
import Vapor
import Fluent
import Foundation
import VaporTurnstile
import TurnstileCrypto

final class User: Model, Account {
    public var realm: Realm.Type = DatabaseRealm.self

    var id: Node?
    var accountID: String {
        return id.string ?? ""
    }
    var username: String
    var passwordHash = ""
    var apiKeyID: String
    var apiKeySecret: String
    var facebookID = ""
    var googleID = ""
    
    required init(node: Node, in context: Context) throws {
        username = try node.extract("username")
        passwordHash = try node.extract("password_hash")
        apiKeyID = try node.extract("api_key_id")
        apiKeySecret = try node.extract("api_key_secret")
        facebookID = try node.extract("facebook_id")
        googleID = try node.extract("google_id")
    }

    static func prepare(_ database: Database) throws {
        try database.create("users") { users in
            users.id()
            users.string("username")
            users.string("password_hash")
            users.string("api_key_id")
            users.string("api_key_secret")
            users.string("facebook_id")
            users.string("google_id")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "username": username,
            "password_hash": passwordHash,
            "api_key_id": apiKeyID,
            "api_key_secret": apiKeySecret,
            "facebook_id": facebookID,
            "google_id": googleID
            ])
    }
    
    convenience init(credentials: UsernamePassword) {
        self.init(username: credentials.username)
        self.passwordHash = BCrypt.hash(password: credentials.password)
    }
    
    convenience init(credentials: FacebookAccount) {
        self.init(username: "\(credentials.dynamicType)\(credentials.accountID)")
        self.facebookID = credentials.accountID
    }
    
    convenience init(credentials: GoogleAccount) {
        self.init(username: "\(credentials.dynamicType)\(credentials.accountID)")
        self.googleID = credentials.accountID
    }
    
    private init(username: String) {
        self.username = username
        self.apiKeyID = String(arc4random_uniform(1000000))
        self.apiKeySecret = String(arc4random_uniform(1000000))
    }
}
