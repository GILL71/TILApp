import Vapor
import Crypto

struct UsersController: RouteCollection {

    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
//        usersRoute.post(User.self, use: createHandler) // - for not authed users
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
        usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
        
        //admin user version
//        let tokenAuthMiddleware = User.tokenAuthMiddleware()
//        let guardAuthMiddleware = User.guardAuthMiddleware()
//        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
//        tokenAuthGroup.post(User.self, use: createHandler)
        
        usersRoute.post("register", use: createHandler)
    }
    
//    func createHandler(_ req: Request, user: User) throws -> Future<Token> {
//        user.password = try BCrypt.hash(user.password)
//
//        user.create(on: req).convertToPublic()
//
//        let token = try Token.generate(for: user)
//
//        return token.save(on: req)
//    }
    
    //неправильный вариант, но рабочий - надо добавить шифрование пароля
    //        return try req.content.decode(User.self).save(on: req).flatMap(to: Token.self) { user in
    //            let token = try Token.generate(for: user)
    //            return token.save(on: req)
    //        }
    
    func createHandler(_ req: Request) throws -> Future<Token> {
        return try req.content.decode(User.self).flatMap({ (user) -> EventLoopFuture<Token> in
//            var userToSave = user
            user.password = try BCrypt.hash(user.password)
            return user.save(on: req).flatMap(to: Token.self) { user in
                let token = try Token.generate(for: user)
                return token.save(on: req)
            }
        })
    }
    
    //admin user version
//    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
//        user.password = try BCrypt.hash(user.password)
//        return user.save(on: req).convertToPublic()
//    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func getAcronymsHandler(_ req: Request)
        throws -> Future<[Acronym]> {
            return try req
                .parameters.next(User.self)
                .flatMap(to: [Acronym].self) { user in
                    try user.acronyms.query(on: req).all()
            }
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
}
