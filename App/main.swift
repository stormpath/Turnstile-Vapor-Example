import Vapor
import VaporMustache
import VaporTurnstile
import VaporMySQL
import Turnstile
import HTTP
import TurnstileWeb

/**
    Adding a provider allows it to boot
    and initialize itself as a dependency.

    Includes are relative to the Views (`Resources/Views`)
    directory by default.
*/
let mustache = VaporMustache.Provider(withIncludes: [
    "header": "Includes/header.mustache",
    "footer": "Includes/footer.mustache"
])

let facebook = FacebookRealm(clientID: "clientID", clientSecret: "clientSecret", callbackURI: "callbackURI")

let mysql = try VaporMySQL.Provider(host: "host", user: "username", password: "password", database: "database")

let turnstile = TurnstileProvider(realm: DatabaseRealm())

/**
    Droplets are service containers that make accessing
    all of Vapor's features easy. Just call
    `drop.serve()` to serve your application
    or `drop.client()` to create a client for
    request data from other servers.
*/
let drop = Droplet(preparations: [User.self, Note.self], initializedProviders: [mustache, turnstile, mysql])

/**
    This first route will return the welcome.html
    view to any request to the root directory of the website.

    Views referenced with `app.view` are by default assumed
    to live in <workDir>/Resources/Views/ 

    You can override the working directory by passing
    --workDir to the application upon execution.
*/
drop.get("/") { request in
    if request.user.authenticated {
        return Response(redirect: "/notes")
    } else {
        return try drop.view("index.mustache")
    }
}

drop.get("/login") { request in
    return try drop.view("login.mustache")
}

drop.post("/login") { request in
    do {
        let loginRequest = try LoginRequest(request: request)
        // Attempt to login, or error
        
        try request.user.login(credentials: UsernamePassword(username: loginRequest.email.value, password: loginRequest.password.value), persist: true)

        return Response(redirect: "/")
    } catch let error as ValidationErrorProtocol {
        return try drop.view("login.mustache", context: ["flash": error.message])
    } catch let error as IncorrectCredentialsError {
        return try drop.view("login.mustache", context: ["flash": "Incorrect username or password"])
    }
}

drop.get("/register") { request in
    return try drop.view("register.mustache")
}

drop.post("/register") { request in
    do {
        let loginRequest = try LoginRequest(request: request)
        let credentials = UsernamePassword(username: loginRequest.email.value, password: loginRequest.password.value)
        // Attempt to login, or error
        
        try request.user.register(credentials: credentials)
        try request.user.login(credentials: credentials, persist: true)
        
        return Response(redirect: "/")
    } catch let error as ValidationErrorProtocol {
        return try drop.view("register.mustache", context: ["flash": error.message])
    }
}

drop.post("/logout") { request in
    request.user.logout()
    return Response(redirect: "/")
}

drop.group(CookieAuthenticationRequired()) { group in
    group.get("/notes") { request in
        var notes = try Note.forUser(id: (request.account?.id)!).all()
        
        let notesContext = notes.map({ (note) -> [String: String] in
            let id = (note.id?.string)!
            let note = note.note
            return ["id": id, "note": note]
        })
        return try drop.view("dashboard.mustache", context: ["authenticated": true, "note": notesContext])
    }
    
    group.get("/notes/new") { request in
        return try drop.view("note.mustache", context: ["authenticated": true])
    }
    
    group.post("/notes/new") { request in
        let saveNotesRequest = try SaveNoteRequest(request: request)
        let userId = Int((request.user.authDetails?.account.accountID)!)!
        var note = Note(userId: userId, note: saveNotesRequest.note)
        try note.save()
        
        let notesContext = ["note": note.note]
        return Response(redirect: "/notes/" + (note.id?.string)!)
    }
    
    group.get("/notes/:id") { request in
        guard let note = try Note.forUser(id: (request.account?.id)!).filter("id", request.parameters["id"]!).first() else {
            return "404"
        }
        
        let notesContext = ["note": note.note]
        return try drop.view("note.mustache", context: ["authenticated": true, "note": notesContext])
    }
    
    group.post("/notes/:id") { request in
        let saveNotesRequest = try SaveNoteRequest(request: request)
        
        guard let querriedNote = try Note.forUser(id: (request.account?.id)!).filter("id", request.parameters["id"]!).first() else {
            throw Abort.notFound
        }
        var note = querriedNote
        
        note.note = saveNotesRequest.note
        try note.save()
        
        let notesContext = ["note": note.note]
        return try drop.view("note.mustache", context: ["authenticated": true, "note": notesContext])
    }
}

drop.group(APIKeyAuthenticationRequired()) { group in
    group.get("/api/notes") { request in
        var notes = try Note.forUser(id: (request.account?.id)!).all()
        
        let notesArray = try notes.map({ (note) -> JSON in
            let id = (note.id?.int)!
            let text = note.note
            return try JSON(["id": id, "note": text])
        })
        return JSON(notesArray)
    }
}

drop.get("/login/facebook/authorize") { request in
    return Response(redirect: facebook.getLoginLink(redirectURL: "http://localhost:8080/login/facebook/callback", state: "12345"))
}

drop.get("/login/facebook/callback") { request in
    let token = try facebook.exchange(authorizationCodeCallbackURL: request.uri.string, state: "12345")
    let credentials = try facebook.authenticate(credentials: token)
    
    do {
        try request.user.login(credentials: credentials, persist: true)
        return Response(redirect: "/")
    }
    catch let error as IncorrectCredentialsError {
        return try drop.view("login.mustache", context: ["flash": "Incorrect username or password"])
    }
}

// Print what link to visit for default port
drop.serve()
