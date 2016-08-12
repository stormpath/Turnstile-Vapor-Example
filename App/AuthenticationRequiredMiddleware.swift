//
//  AuthenticationRequiredMiddleware.swift
//  VaporApp
//
//  Created by Edward Jiang on 7/27/16.
//
//

import Vapor
import HTTP
import URI
import Turnstile

class CookieAuthenticationRequired: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if request.user.authDetails?.sessionID != nil {
            return try next.respond(to: request)
        } else {
            return Response(redirect: "/")
        }
    }
}

class APIKeyAuthenticationRequired: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if request.user.authDetails?.credentialType is APIKey.Type {
            return try next.respond(to: request)
        } else {
            return try Response(status: .unauthorized, json: JSON(["error": "401 Unauthorized"]))
        }
    }
}

extension Request {
    var account: User? {
        return self.user.authDetails?.account as? User
    }
}

extension URI {
    var string: String {
        return "\(scheme)://\(host):\(port!)\(path)?\(query ?? "")"
    }
}
