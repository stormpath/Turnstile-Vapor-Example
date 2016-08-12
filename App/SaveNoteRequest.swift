//
//  SaveNoteRequest.swift
//  VaporApp
//
//  Created by Edward Jiang on 7/27/16.
//
//

import Vapor
import HTTP

class SaveNoteRequest {
    let id: Int?
    let note: String
    
    init(request: Request) throws {
        if let id = request.formURLEncoded?["id"]?.int {
            self.id = Int(id)
        } else {
            self.id = nil
        }
        note = request.data["note"]?.string ?? ""
    }
}
