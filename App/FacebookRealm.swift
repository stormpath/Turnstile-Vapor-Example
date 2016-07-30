//
//  FacebookRealm.swift
//  VaporApp
//
//  Created by Edward Jiang on 7/29/16.
//
//

import Turnstile
import Vapor
import Engine

class FacebookRealm: Realm {
    let clientID: String
    let clientSecret: String
    
    var appAccessToken: String {
        return clientID + "%7C" + clientSecret
    }
    
    func authenticate(credentials: Credentials) throws -> Account {
        switch credentials {
        case let credentials as TokenCredentials:
            return try authenticate(credentials: credentials)
        case let credentials as AuthorizationCode:
            return try authenticate(credentials: credentials)
        default:
            throw UnsupportedCredentialsError()
        }
    }
    
    func authenticate(credentials: TokenCredentials) throws -> FacebookAccount {
        let url = "https://graph.facebook.com/debug_token?input_token=" + credentials.token + "&access_token=" + appAccessToken
        let request = try! HTTPRequest(method: .get, uri: url)
        request.headers["Accept"] = "application/json"
        
        guard let response = try? Engine.HTTPClient<TCPClientStream>.respond(to: request),
            responseData = response.json?["data"] as? JSON else { throw UnsupportedCredentialsError() }
        
        if let accountID = responseData["user_id"].string
            where responseData["app_id"].string == clientID && responseData["is_valid"].bool == true {
            return FacebookAccount(accountID: accountID)
        }
        
        throw IncorrectCredentialsError()
    }
    
    func authenticate(credentials: AuthorizationCode) throws -> FacebookAccount {
        let url = "https://graph.facebook.com/v2.3/oauth/access_token?client_id=\(clientID)&redirect_uri=\(credentials.redirectURI)&client_secret=\(clientSecret)&code=\(credentials.code)"
        let request = try! HTTPRequest(method: .get, uri: url)
        request.headers["Accept"] = "application/json"
        
        guard let response = try? Engine.HTTPClient<TCPClientStream>.respond(to: request),
            accessToken = response.json?["access_token"].string else {
                throw UnsupportedCredentialsError()
        }
        return try authenticate(credentials: TokenCredentials(token: accessToken))
    }
    
    func register(credentials: Credentials) throws -> Account {
        throw UnsupportedCredentialsError()
    }
    
    init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
}

struct AuthorizationCode: Credentials {
    let code: String
    let redirectURI: String
}

struct FacebookAccount: Account, Credentials {
    let accountID: String
}
