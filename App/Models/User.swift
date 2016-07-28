
import Turnstile
import Fluent
import Foundation

final class User: Model, Account {
    var id: Value?
    var accountID: String? {
        return id?.string
    }
    var username: String
    var passwordHash: String
    var apiKeyID: String
    var apiKeySecret: String
    
    init(serialized: [String: Value]) {
        // Should figure out the optional Model initializer?
        username = serialized["username"]?.string ?? ""
        passwordHash = serialized["passwordHash"]?.string ?? ""
        apiKeyID = serialized["apiKeyID"]?.string ?? ""
        apiKeySecret = serialized["apiKeySecret"]?.string ?? ""
    }
    
    init(credentials: PasswordCredentials) {
        self.username = credentials.username
        self.passwordHash = drop.hash.make(credentials.password)
        self.apiKeyID = String(arc4random_uniform(1000000))
        self.apiKeySecret = String(arc4random_uniform(1000000))
    }
}

class DatabaseRealm: Realm {
    func canAuthenticate(credentialType: Credentials.Type) -> Bool {
        return credentialType is PasswordCredentials.Type || credentialType is APIKeyCredentials.Type
    }
    func authenticate(credentials: Credentials) throws -> Account {
        // TODO: Insecure -- just prototyping
        switch credentials {
        case let credentials as PasswordCredentials:
            guard let match = try User.filter("username", credentials.username).first() else { throw IncorrectCredentialsError() }
            
            if match.passwordHash == drop.hash.make(credentials.password) {
                return match
            } else {
                throw IncorrectCredentialsError()
            }
        case let credentials as APIKeyCredentials:
            guard let match = try User.filter("apiKeyID", credentials.id).filter("apiKeySecret", credentials.secret).first() else {
                throw IncorrectCredentialsError()
            }
            return match
        default:
            throw IncorrectCredentialsError()
        }
    }
    
    func canRegister(credentialType: Credentials.Type) -> Bool {
        return credentialType is PasswordCredentials.Type
    }
    func register(credentials: Credentials) throws -> Account {
        guard let credentials = credentials as? PasswordCredentials else { throw IncorrectCredentialsError() }
        var user = User(credentials: credentials)
        try user.save()
        return user
    }
}

