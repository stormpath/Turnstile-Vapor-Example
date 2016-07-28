//
//  AuthenticationRequiredMiddleware.swift
//  VaporApp
//
//  Created by Edward Jiang on 7/27/16.
//
//

import Vapor

class AuthenticationRequiredMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if request.subject.authenticated {
            return try next.respond(to: request)
        } else {
            return Response(redirect: "/")
        }
    }
}
