//
//  AuthenticationRequiredMiddleware.swift
//  VaporApp
//
//  Created by Edward Jiang on 7/27/16.
//
//

import Vapor
import Turnstile

class CookieAuthenticationRequired: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if request.subject.authDetails?.sessionID != nil {
            return try next.respond(to: request)
        } else {
            return Response(redirect: "/")
        }
    }
}

class APIKeyAuthenticationRequired: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if request.subject.authDetails?.credentialType is APIKeyCredentials.Type {
            return try next.respond(to: request)
        } else {
            return try Response(status: .unauthorized, json: ["error": "401 Unauthorized"])
        }
    }
}

extension Request {
    var user: User? {
        return self.subject.authDetails?.account as? User
    }
}
