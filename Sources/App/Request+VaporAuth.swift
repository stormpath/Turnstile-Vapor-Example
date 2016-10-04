//
//  Request+VaporAuth.swift
//  VaporAuth
//
//  Created by Edward Jiang on 10/3/16.
//
//

import Turnstile
import HTTP

extension Request {
    // Base URL returns the hostname, scheme, and port in a URL string form.
    var baseURL: String {
        return uri.scheme + "://" + uri.host + (uri.port == nil ? "" : ":\(uri.port!)")
    }
    
    // Exposes the Turnstile subject, as Vapor has a facade on it. 
    var subject: Subject {
        return storage["subject"] as! Subject
    }
}
