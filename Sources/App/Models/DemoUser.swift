//
//  DemoUser.swift
//  VaporAuth
//
//  Created by Edward Jiang on 10/3/16.
//
//

import HTTP
import Fluent
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import Auth

final class DemoUser: User {
    // Field for the Fluent ORM
    var exists: Bool = false
    
    // Database Fields
    var id: Node?
    var username: String
    var password = ""
    var facebookID = ""
    var googleID = ""
    var apiKeyID = URandom().secureToken
    var apiKeySecret = URandom().secureToken
    
    /**
     Authenticates a set of credentials against the User.
     */
    static func authenticate(credentials: Credentials) throws -> User {
        var user: DemoUser?
        
        switch credentials {
        /**
         Fetches a user, and checks that the password is present, and matches.
         */
        case let credentials as UsernamePassword:
            let fetchedUser = try DemoUser.query()
                .filter("username", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
            
        /**
         Fetches the user by session ID. Used by the Vapor session manager.
         */
        case let credentials as Identifier:
            user = try DemoUser.find(credentials.id)
        
        /**
         Fetches the user by Facebook ID. If the user doesn't exist, autoregisters it.
         */
        case let credentials as FacebookAccount:
            if let existing = try DemoUser.query().filter("facebook_id", credentials.uniqueID).first() {
                user = existing
            } else {
                user = try DemoUser.register(credentials: credentials) as? DemoUser
            }
        
        /**
         Fetches the user by Google ID. If the user doesn't exist, autoregisters it.
         */
        case let credentials as GoogleAccount:
            if let existing = try DemoUser.query().filter("google_id", credentials.uniqueID).first() {
                user = existing
            } else {
                user = try DemoUser.register(credentials: credentials) as? DemoUser
            }
        
        /**
         Authenticates via API Keys
         */
        case let credentials as APIKey:
            user = try DemoUser.query()
                .filter("api_key_id", credentials.id)
                .filter("api_key_secret", credentials.secret)
                .first()
            
        default:
            throw UnsupportedCredentialsError()
        }
        
        if let user = user {
            return user
        } else {
            throw IncorrectCredentialsError()
        }
    }
    
    /**
     Registers users for UsernamePassword, Facebook, or Google accounts.
     */
    static func register(credentials: Credentials) throws -> User {
        var newUser: DemoUser
        
        switch credentials {
        case let credentials as UsernamePassword:
            newUser = DemoUser(credentials: credentials)
        case let credentials as FacebookAccount:
            newUser = DemoUser(credentials: credentials)
        case let credentials as GoogleAccount:
            newUser = DemoUser(credentials: credentials)
        default:
            throw UnsupportedCredentialsError()
        }
        
        if try DemoUser.query().filter("username", newUser.username).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }

    }
    
    init(credentials: UsernamePassword) {
        self.username = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
    }
    
    init(credentials: FacebookAccount) {
        self.username = "fb" + credentials.uniqueID
        self.facebookID = credentials.uniqueID
    }
    
    init(credentials: GoogleAccount) {
        self.username = "goog" + credentials.uniqueID
        self.googleID = credentials.uniqueID
    }
    
    /**
     Initializer for Fluent
     */
    init(node: Node, in context: Context) throws {
        id = node["id"]
        username = try node.extract("username")
        password = try node.extract("password")
        facebookID = try node.extract("facebook_id")
        googleID = try node.extract("google_id")
        apiKeyID = try node.extract("api_key_id")
        apiKeySecret = try node.extract("api_key_secret")
    }
    
    /**
     Serializer for Fluent
     */
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username": username,
            "password": password,
            "facebook_id": facebookID,
            "google_id": googleID,
            "api_key_id": apiKeyID,
            "api_key_secret": apiKeySecret
            ])
    }
    
    static func prepare(_ database: Database) throws {}
    
    static func revert(_ database: Database) throws {}
}

extension Request {
    func user() throws -> DemoUser {
        guard let user = try auth.user() as? DemoUser else {
            throw "Invalid user type"
        }
        return user
    }
}

extension String: Error {}
