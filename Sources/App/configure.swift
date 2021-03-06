//import FluentSQLite
//import Vapor
//
//// Called before your application initializes.
//public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
//    /// Register providers first
//    try services.register(FluentSQLiteProvider())
//
//    /// Register routes to the router
//    let router = EngineRouter.default()
//    try routes(router)
//    services.register(router, as: Router.self)
//
//    /// Register middleware
//    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
//    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
//    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
//    services.register(middlewares)
//
//    // Configure a SQLite database
//    let sqlite = try SQLiteDatabase(storage: .memory)
//
//    /// Register the configured SQLite database to the database config.
//    var databases = DatabasesConfig()
//    databases.add(database: sqlite, as: .sqlite)
//    services.register(databases)
//
//    /// Configure migrations
//    var migrations = MigrationConfig()
//    migrations.add(model: Acronym.self, database: .sqlite)
//    services.register(migrations)
//
//}

import FluentPostgreSQL
import Vapor
import Authentication

//last mine
//public func configure(
//    _ config: inout Config,
//    _ env: inout Environment,
//    _ services: inout Services
//    ) throws {
//    // 2
//    try services.register(FluentPostgreSQLProvider())
//
//    let router = EngineRouter.default()
//    try routes(router)
//    services.register(router, as: Router.self)
//
//    var middlewares = MiddlewareConfig()
//    middlewares.use(ErrorMiddleware.self)
//    services.register(middlewares)
//
//    // 1
//    var databases = DatabasesConfig()
//    // 2
//    let hostname = Environment.get("DATABASE_HOSTNAME")
//        ?? "localhost"
//    let username = Environment.get("DATABASE_USER") ?? "vapor"
//    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
//    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
//    // 3
//    let databaseConfig = PostgreSQLDatabaseConfig(
//        hostname: hostname,
//        username: username,
//        database: databaseName,
//        password: password)
//    // 4
//    let database = PostgreSQLDatabase(config: databaseConfig)
//    // 5
//    databases.add(database: database, as: .psql)
//    // 6
//    services.register(databases)
//
//    var migrations = MigrationConfig()
//    // 4
//    migrations.add(model: Acronym.self, database: .psql)
//    services.register(migrations)
//}

//jonas version
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    // 2
    try services.register(FluentPostgreSQLProvider())
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)
    
    // 1
    var databases = DatabasesConfig()
    // 2
    let databaseConfig: PostgreSQLDatabaseConfig
    if let url = Environment.get("DB_POSTGRESQL") {
        guard let urlConfig = PostgreSQLDatabaseConfig(url: url) else {
            fatalError("Failed to create PostgresConfig")
        }
        databaseConfig = urlConfig
    } else {
        let hostname = Environment.get("DATABASE_HOSTNAME")
            ?? "localhost"
        let username = Environment.get("DATABASE_USER") ?? "vapor"
        let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
        let password = Environment.get("DATABASE_PASSWORD") ?? "password"
        // 3
        databaseConfig = PostgreSQLDatabaseConfig(
            hostname: hostname,
            username: username,
            database: databaseName,
            password: password)
        // 4
    }
    let database = PostgreSQLDatabase(config: databaseConfig)
    // 5
    databases.add(database: database, as: .psql)
    // 6
    services.register(databases)
    
    //?
    
    try services.register(AuthenticationProvider())
    //?
    
    var migrations = MigrationConfig()
    // 4
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(migration: AdminUser.self, database: .psql)
    services.register(migrations)
    
    let websockets = NIOWebSocketServer.default()
    sockets(websockets)
    services.register(websockets, as: WebSocketServer.self)
}
