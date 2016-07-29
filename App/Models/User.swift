
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

class DatabaseRealm: Realm {
    func canAuthenticate(credentialType: Credentials.Type) -> Bool {
        return credentialType is PasswordCredentials.Type || credentialType is APIKeyCredentials.Type || credentialType is FacebookAccount.Type
    }
    
    func authenticate(credentials: Credentials) throws -> Account {
        switch credentials {
        case let credentials as PasswordCredentials:
            return try authenticate(credentials: credentials)
        case let credentials as APIKeyCredentials:
            return try authenticate(credentials: credentials)
        case let credentials as FacebookAccount:
            return try authenticate(credentials: credentials)
        default:
            throw UnsupportedCredentialsError()
        }
    }
    
    func authenticate(credentials: PasswordCredentials) throws -> Account {
        guard let match = try User.filter("username", credentials.username).first() else { throw IncorrectCredentialsError() }
        
        if match.passwordHash == drop.hash.make(credentials.password) {
            return match
        } else {
            throw IncorrectCredentialsError()
        }
    }
    
    func authenticate(credentials: APIKeyCredentials) throws -> Account {
        guard let match = try User.filter("apiKeyID", credentials.id).filter("apiKeySecret", credentials.secret).first() else {
            throw IncorrectCredentialsError()
        }
        return match
    }
    
    func authenticate(credentials: FacebookAccount) throws -> Account {
        guard let match = try User.filter("facebookID", credentials.accountID).first() else {
            throw IncorrectCredentialsError()
        }
        
        if match.facebookID == credentials.accountID {
            return match
        } else {
            throw IncorrectCredentialsError()
        }
    }
    
    func canRegister(credentialType: Credentials.Type) -> Bool {
        return credentialType is PasswordCredentials.Type
    }
    
    func register(credentials: Credentials) throws -> Account {
        throw UnsupportedCredentialsError()
    }
    
    func register(credentials: PasswordCredentials) throws -> Account {
        var user = User(credentials: credentials)
        try user.save()
        return user
    }
}

