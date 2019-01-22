//import Vapor
//import FluentSQLite
//
//final class Acronym: Codable {
//    var id: Int?
//    var short: String
//    var long: String
//
//    init(short: String, long: String) {
//        self.short = short
//        self.long = long
//    }
//}
//
//extension Acronym: Model {
//    // 1
//    typealias Database = SQLiteDatabase
//    // 2
//    typealias ID = Int
//    // 3
//    public static var idKey: IDKey = \Acronym.id
//}

//extension Acronym: SQLiteModel {} //contains in protocol id: Int property
//
//extension Acronym: Migration {}
//
//extension Acronym: Content {}

import Vapor
import FluentPostgreSQL

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    var userID: User.ID?

    init(short: String, long: String, userID: User.ID?) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

//docker run --name postgres -e POSTGRES_DB=vapor \
//-e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password \
//-p 5432:5432 -d postgres
extension Acronym: PostgreSQLModel {}
//extension Acronym: Migration {}
extension Acronym: Content {}
extension Acronym: Parameter {}

extension Acronym {
    // 1
    var user: Parent<Acronym, User>? {
        // 2
        return parent(\.userID)
    }
}

extension Acronym: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
