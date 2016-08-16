//
//  DatabaseRealm.swift
//  VaporApp
//
//  Created by Edward Jiang on 7/29/16.
//
//

import Turnstile
import TurnstileWeb
import TurnstileCrypto
import VaporTurnstile

class DatabaseRealm: Realm {
    func authenticate(credentials: Credentials) throws -> Account {
        switch credentials {
        case let credentials as UsernamePassword:
            return try authenticate(credentials: credentials)
        case let credentials as APIKey:
            return try authenticate(credentials: credentials)
        case let credentials as FacebookAccount:
            return try authenticate(credentials: credentials)
        case let credentials as GoogleAccount:
            return try authenticate(credentials: credentials)
        default:
            throw UnsupportedCredentialsError()
        }
    }
    
    func authenticate(credentials: UsernamePassword) throws -> Account {
        guard let match = try User.query().filter("username", credentials.username).first() else { throw IncorrectCredentialsError() }
        
        if try! BCrypt.verify(password: credentials.password, matchesHash: match.passwordHash) {
            return match
        } else {
            throw IncorrectCredentialsError()
        }
    }
    
    func authenticate(credentials: APIKey) throws -> Account {
        guard let match = try User.query().filter("api_key_id", credentials.id).filter("api_key_secret", credentials.secret).first() else {
            throw IncorrectCredentialsError()
        }
        return match
    }
    
    func authenticate(credentials: FacebookAccount) throws -> Account {
        guard let match = try User.query().filter("facebook_id", credentials.accountID).first() else {
            var user = User(credentials: credentials)
            try user.save()
            return user
        }
        return match
    }
    
    func authenticate(credentials: GoogleAccount) throws -> Account {
        guard let match = try User.query().filter("google_id", credentials.accountID).first() else {
            var user = User(credentials: credentials)
            try user.save()
            return user
        }
        return match
    }
    
    func register(credentials: Credentials) throws -> Account {
        switch credentials {
        case let credentials as UsernamePassword:
            return try register(credentials: credentials)
        default:
            throw UnsupportedCredentialsError()
        }
    }
    
    func register(credentials: UsernamePassword) throws -> Account {
        var user = User(credentials: credentials)
        try user.save()
        return user
    }
}
