//
//  APIAuthenticationMiddleware.swift
//  VaporAuth
//
//  Created by Edward Jiang on 10/3/16.
//
//

import Vapor
import HTTP
import Turnstile

class APIAuthenticationMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let apiKey = request.auth.header?.basic {
            try? request.auth.login(apiKey, persist: false)
        }
        
        return try next.respond(to: request)
    }
}
