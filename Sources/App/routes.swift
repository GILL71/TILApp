import Vapor
import Fluent

let sessionManager = TrackingSessionManager()

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
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
    
    router.get("api", "acronyms", Acronym.parameter) {
        req -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) {
            acronym, updatedAcronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req)
        }
    }

    router.delete("api", "acronyms", Acronym.parameter) {
        req -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    router.get("api", "acronyms", "search") {
        req -> Future<[Acronym]> in
        // 2
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        // 3
        return Acronym.query(on: req)
            .filter(\.short == searchTerm)
            .all()
    }
    
    let acronymsController = AcronymsController()

    try router.register(collection: acronymsController)
    
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
        // 2
        let session = try req.parameters.next(TrackingSession.self)
        // 3
        return try Message.decode(from: req)
            .map(to: HTTPStatus.self) { message in
                // 4
//                message.content = "catched message!"
                sessionManager.update(message, for: session)
                return .ok
        }
    }
}
//wood.frog.deer
