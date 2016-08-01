//
//  DatabaseRealm.swift
//  VaporApp
//
//  Created by Edward Jiang on 7/29/16.
//
//

import Turnstile
import VaporTurnstile

class DatabaseRealm: Realm {
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
    
    func register(credentials: Credentials) throws -> Account {
        throw UnsupportedCredentialsError()
    }
    
    func register(credentials: PasswordCredentials) throws -> Account {
        var user = User(credentials: credentials)
        try user.save()
        return user
    }
}
