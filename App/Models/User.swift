
import Turnstile
import Fluent
import Foundation

final class User: Model, Account {
    var id: Value?
    var accountID: String {
        return id.string ?? ""
    }
    var username: String
    var passwordHash: String
    var apiKeyID: String
    var apiKeySecret: String
    var facebookID: String
    
    init(serialized: [String: Value]) {
        // Should figure out the optional Model initializer?
        username = serialized["username"]?.string ?? ""
        passwordHash = serialized["passwordHash"]?.string ?? ""
        apiKeyID = serialized["apiKeyID"]?.string ?? ""
        apiKeySecret = serialized["apiKeySecret"]?.string ?? ""
        facebookID = serialized["facebookID"]?.string ?? ""
    }
    
    init(credentials: PasswordCredentials) {
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
