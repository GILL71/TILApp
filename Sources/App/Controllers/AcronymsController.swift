import Vapor
import Fluent
import Authentication

struct AcronymsController: RouteCollection {
    
    func boot(router: Router) throws {
        let acronymsRoutes = router.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.get(Acronym.parameter, use: getHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get(Acronym.parameter, "user", use: getUserHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = acronymsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        //group above acronymsRoutes
        tokenAuthGroup.post(AcronymCreateData.self, use: createHandler)
        tokenAuthGroup.delete(Acronym.parameter, use: deleteHandler)
        tokenAuthGroup.put(Acronym.parameter, use: updateHandler)
        
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    func createHandler(_ req: Request, data: AcronymCreateData) throws -> Future<Acronym> {
        let user = try req.requireAuthenticated(User.self)
        let acronym = try Acronym(short: data.short,
                                  long: data.long,
                                  userID: user.requireID())
        return acronym.save(on: req)
    }
    
//    func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
//        return acronym.save(on: req)
//    }
//    func createHandler(_ req: Request) throws -> Future<Acronym> {
//        return try req
//            .content
//            .decode(Acronym.self)
//            .flatMap(to: Acronym.self) { acronym in
//                return acronym.save(on: req)
//        }
//    }
    
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(AcronymCreateData.self)) { acronym, updateData in
                                acronym.short = updateData.short
                                acronym.long = updateData.long
                                let user = try req.requireAuthenticated(User.self)
                                acronym.userID = try user.requireID()
                                return acronym.save(on: req)
                            }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
            .parameters
            .next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req
            .query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
            }.all()
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req
            .parameters.next(Acronym.self)
            .flatMap(to: User.Public.self) { acronym in
                guard let user = acronym.user?.get(on: req) else {
                    throw Abort(.notFound)
                }
                return user.convertToPublic()
        }
    }
    
}

struct AcronymCreateData: Content {
    let short: String
    let long: String
}
