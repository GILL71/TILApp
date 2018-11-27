import Vapor
import FluentSQLite

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
}

//extension Acronym: Model {
//    // 1
//    typealias Database = SQLiteDatabase
//    // 2
//    typealias ID = Int
//    // 3
//    public static var idKey: IDKey = \Acronym.id
//}

extension Acronym: SQLiteModel {} //contains in protocol id: Int property

extension Acronym: Migration {}

extension Acronym: Content {}
