import Vapor
import VaporMustache
import VaporTurnstile
import VaporMySQL
import Turnstile

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

let mysql = try VaporMySQL.Provider(host: "host", user: "username", password: "password", database: "database")

let turnstile = VaporTurnstile(realms: [DatabaseRealm()])

/**
    Xcode defaults to a working directory in
    a temporary build folder. 
    
    In order for Vapor to access Resources and
    Configuration files, the working directory
    must be the root directory of your project.
 
    This can also be achieved by passing
    --workDir=$(SRCROOT) in the Xcode arguments
    or setting the root directory manually in:
    Edit Scheme > Options > [ ] Use custom working directory
*/
let workDir: String?
#if Xcode
    let parent = #file.characters.split(separator: "/").map(String.init).dropLast().joined(separator: "/")
    workDir = "/\(parent)/.."
#else
    workDir = nil
#endif

/**
    Droplets are service containers that make accessing
    all of Vapor's features easy. Just call
    `drop.serve()` to serve your application
    or `drop.client()` to create a client for
    request data from other servers.
*/
let drop = Droplet(workDir: workDir, preparations: [User.self], providers: [mustache, turnstile, mysql])

/**
    This first route will return the welcome.html
    view to any request to the root directory of the website.

    Views referenced with `app.view` are by default assumed
    to live in <workDir>/Resources/Views/ 

    You can override the working directory by passing
    --workDir to the application upon execution.
*/
drop.get("/") { request in
    guard request.subject.authentiated else {
        return try drop.view("index.mustache")
    }
    
    return try drop.view("dashboard.mustache", context: ["authenticated": true])
}

drop.get("/login") { request in
    return try drop.view("login.mustache")
}

drop.post("/login") { request in
    do {
        let loginRequest = try LoginRequest(request: request)
        // Attempt to login, or error
        
        try request.subject.login(credentials: UsernamePasswordCredentials(username: loginRequest.email.value, password: loginRequest.password.value))

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
        // Attempt to login, or error
        
        try request.subject.register(credentials: UsernamePasswordCredentials(username: loginRequest.email.value, password: loginRequest.password.value))
        
        return Response(redirect: "/")
    } catch let error as ValidationErrorProtocol {
        return try drop.view("register.mustache", context: ["flash": error.message])
    }
}

drop.post("/logout") { request in
    request.subject.logout()
    return Response(redirect: "/")
}

// Print what link to visit for default port
drop.serve()
