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
    var baseURL: String {
        return uri.scheme + "://" + uri.host + (uri.port == nil ? "" : ":\(uri.port!)")
    }
    
    var subject: Subject {
        return storage["subject"] as! Subject
    }
}
