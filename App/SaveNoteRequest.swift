//
//  SaveNoteRequest.swift
//  VaporApp
//
//  Created by Edward Jiang on 7/27/16.
//
//

import Vapor

class SaveNoteRequest {
    let id: Int?
    let note: String
    
    init(request: Request) throws {
        // Need to figure out a better way to pin to formurlencoded
        if let id = request.data["id"]?.int {
            self.id = Int(id)
        } else {
            self.id = nil
        }
        note = request.data["note"]?.string ?? ""
    }
}
