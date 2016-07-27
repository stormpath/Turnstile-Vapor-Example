
import Turnstile
import Fluent

final class User: Model, Account {
    var id: Value?
    var accountID: String? {
        return id?.string
    }
    var username: String
    var passwordHash: String
    
    init(serialized: [String: Value]) {
        // Should figure out the optional Model initializer?
        username = serialized["username"]?.string ?? ""
        passwordHash = serialized["passwordHash"]?.string ?? ""
    }
    
    init(credentials: UsernamePasswordCredentials) {
        self.username = credentials.username
        self.passwordHash = drop.hash.make(credentials.password)
    }
}

class DatabaseRealm: Realm {
    func authenticate(credentials: Credentials) throws -> Account {
        // TODO: Insecure -- just prototyping
        guard let credentials = credentials as? UsernamePasswordCredentials else { throw IncorrectCredentialsError() }
        guard let match = try Query<User>().filter("username", credentials.username).first() else { throw IncorrectCredentialsError() }
        
        if match.passwordHash == drop.hash.make(credentials.password) {
            return match
        } else {
            throw IncorrectCredentialsError()
        }
        
    }
    func register(credentials: Credentials) throws -> Account {
        guard let credentials = credentials as? UsernamePasswordCredentials else { throw IncorrectCredentialsError() }
        var user = User(credentials: credentials)
        try user.save()
        let databasestuff = Database.map
        print(databasestuff)
        return user
    }
    func supports(credentials: Credentials) -> Bool {
        return credentials is UsernamePasswordCredentials
    }
}

