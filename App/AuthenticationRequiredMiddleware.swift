//
//  AuthenticationRequiredMiddleware.swift
//  VaporApp
//
//  Created by Edward Jiang on 7/27/16.
//
//

import Vapor
import Turnstile
import CryptoEssentials

class CookieAuthenticationRequired: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if request.subject.authenticated && request.subject.authDetails?.credentialType is PasswordCredentials.Type {
            return try next.respond(to: request)
        } else {
            return Response(redirect: "/")
        }
    }
}

class APIKeyAuthenticationRequired: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let credentials = request.auth?.basic else {
            return try Response(status: .unauthorized, json: ["error": "401 Unauthorized"])
        }
        
        do {
            try request.subject.login(credentials: credentials)
        } catch {
            return try Response(status: .unauthorized, json: ["error": "401 Unauthorized"])
        }
        
        if request.subject.authenticated && request.subject.authDetails?.credentialType is APIKeyCredentials.Type {
            return try next.respond(to: request)
        } else {
            return try Response(status: .unauthorized, json: ["error": "401 Unauthorized"])
        }
    }
}

extension Request {
    var auth: AuthorizationHeader? {
        return AuthorizationHeader(value: self.headers["Authorization"])
    }
}

extension Request {
    var user: User? {
        return self.subject.authDetails?.account as? User
    }
}

struct AuthorizationHeader {
    let headerValue: String
    
    init?(value: String?) {
        guard let value = value else { return nil }
        headerValue = value
    }
    
    var basic: APIKeyCredentials? {
        guard let range = headerValue.range(of: "Basic ") else { return nil }
        let token = headerValue.substring(from: range.upperBound)
        
        let decodedToken: String
        do {
            decodedToken = try Base64.decode(token).string()
        } catch {
            return nil
        }
        
        guard let separatorRange = decodedToken.range(of: ":") else {
            return nil
        }
        
        let apiKeyID = decodedToken.substring(to: separatorRange.lowerBound)
        let apiKeySecret = decodedToken.substring(from: separatorRange.upperBound)
        
        return APIKeyCredentials(id: apiKeyID, secret: apiKeySecret)
    }
    
    var bearer: TokenCredentials? {
        guard let range = headerValue.range(of: "Bearer ") else { return nil }
        let token = headerValue.substring(from: range.upperBound)
        return TokenCredentials(token: token)
    }
}
