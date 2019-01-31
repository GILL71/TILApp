import Vapor
import Fluent
import SwiftSMTP

let sessionManager = TrackingSessionManager()

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    router.get("zdarova") { req in
        return "Здарова, Димон, это привет тебе от кента с 5ого этажа!"
    }
    
//    router.post("api", "acronyms") { req -> Future<Acronym> in
//        return try req.content.decode(Acronym.self)
//            .flatMap(to: Acronym.self) { acronym in
//                return acronym.save(on: req)
//        }
//    }
    
//    router.get("api", "acronyms") { req -> Future<[Acronym]> in
//        return Acronym.query(on: req).all()
//    }
    
//    router.get("api", "users") { req -> Future<[User]> in
//        return User.query(on: req).all()
//    }
//
//    router.post("api", "users") { req -> Future<User> in
//        return try req.content.decode(User.self)
//            .flatMap(to: User.self) { user in
//            return user.save(on: req)
//        }
//    }
    
//    router.get("api", "acronyms", Acronym.parameter) {
//        req -> Future<Acronym> in
//        return try req.parameters.next(Acronym.self)
//    }
    
//    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
//        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) {
//            acronym, updatedAcronym in
//            acronym.short = updatedAcronym.short
//            acronym.long = updatedAcronym.long
//            return acronym.save(on: req)
//        }
//    }

//    router.delete("api", "acronyms", Acronym.parameter) {
//        req -> Future<HTTPStatus> in
//        return try req.parameters.next(Acronym.self)
//            .delete(on: req)
//            .transform(to: HTTPStatus.noContent)
//    }
    
//    router.get("api", "acronyms", "search") {
//        req -> Future<[Acronym]> in
//        // 2
//        guard let searchTerm = req.query[String.self, at: "term"] else {
//            throw Abort(.badRequest)
//        }
//        // 3
//        return Acronym.query(on: req)
//            .filter(\.short == searchTerm)
//            .all()
//    }
    
    router.post("api", "sendMail") { (req) -> Future<HTTPStatus> in
        
        return try req.content.decode(TicketPass.self).map(to: HTTPStatus.self, { (pass) -> HTTPStatus in
            
            guard let email = ProcessInfo.processInfo.environment["tsmp_email_var"] else {
                return HTTPStatus.conflict
            }
            guard let password = ProcessInfo.processInfo.environment["tsmp_pass_var"] else {
                return HTTPStatus.conflict
            }
            
            let smtp = SMTP(hostname: "smtp.gmail.com",
                            email: email,
                            password: password,
                            port: 587,
                            tlsMode: .requireSTARTTLS,
                            tlsConfiguration: nil,
                            authMethods: [],
                            domainName: "localhost",
                            timeout: 10)
            
            let commail = Mail.User(name: "Michael Nechaev", email: "gm360s@gmail.com")
            let rumail = Mail.User(name: pass.name, email: pass.recipientEmail ?? "No name")
            
            let mail = Mail(
                from: commail,
                to: [rumail],
                subject: pass.header ?? "-",
                text: pass.text ?? "No body"
            )
            
            smtp.send(mail) { (error) in
                if let error = error {
                    print(error)
                }
            }
            return .ok
        })
        
    }
    
    router.post("api", "create", use: sessionManager.createTrackingSession)
    
    router.post("close", TrackingSession.parameter) {
        req -> HTTPStatus in
        let session = try req.parameters.next(TrackingSession.self)
        sessionManager.close(session)
        return .ok
    }
    
    router.get("word-test") { request in
        return wordKey(with: request)
    }
    
    router.post("api", "update", TrackingSession.parameter) {
        req -> Future<HTTPStatus> in
        let session = try req.parameters.next(TrackingSession.self)
        return try Message.decode(from: req)
            .map(to: HTTPStatus.self) { message in
                sessionManager.update(message, for: session)
                return .ok
        }
    }
    
    let acronymsController = AcronymsController()
    try router.register(collection: acronymsController)
    
    let usersController = UsersController()
    try router.register(collection: usersController)
}
