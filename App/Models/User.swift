import Turnstile
import TurnstileWeb
import Vapor
import Fluent
import Foundation
import VaporTurnstile

final class User: Model, Account {
    var id: Node?
    var accountID: String {
        return id.string ?? ""
    }
    var username: String
    var passwordHash: String
    var apiKeyID: String
    var apiKeySecret: String
    var facebookID: String
    
    required init(node: Node, in context: Context) throws {
        username = try node.extract("username")
        passwordHash = try node.extract("password_hash")
        apiKeyID = try node.extract("api_key_id")
        apiKeySecret = try node.extract("api_key_secret")
        facebookID = try node.extract("facebook_id")
    }

    static func prepare(_ database: Database) throws {
        try database.create("users") { users in
            users.id()
            users.string("username")
            users.string("password_hash")
            users.string("api_key_id")
            users.string("api_key_secret")
            users.string("facebook_id")
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
            "facebook_id": facebookID
            ])
    }
    
    init(credentials: UsernamePassword) {
        self.username = credentials.username
        self.passwordHash = drop.hash.make(credentials.password)
        self.apiKeyID = String(arc4random_uniform(1000000))
        self.apiKeySecret = String(arc4random_uniform(1000000))
        self.facebookID = ""
    }
    
    init(credentials: FacebookAccount) {
        self.username = credentials.accountID
        self.passwordHash = ""
        self.apiKeyID = String(arc4random_uniform(1000000))
        self.apiKeySecret = String(arc4random_uniform(1000000))
        self.facebookID = credentials.accountID
    }
}
