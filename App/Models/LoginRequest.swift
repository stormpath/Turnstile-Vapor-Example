import Vapor

class LoginRequest {
    let email: Valid<Email>
    let password: Valid<Count<String>>
    
    init(request: Request) throws {
        // Need to figure out a better way to pin to formurlencoded
        email = try request.data["email"].validated()
        password = try request.data["password"].validated(by: Count.min(8))
    }
}
