
import Foundation
import Vapor
import FluentPostgreSQL

final class Message: Codable {
    var id: Int?
    var content: String
    var user_id: Int
    
    init(content: String, user_id: Int) {
        self.content = content
        self.user_id = user_id
    }
}

extension Message: PostgreSQLModel {}
extension Message: Content {}
extension Message: Migration {}
extension Message: Parameter {}

//struct Message: Content {
//    var content: String
//    var user_id: UUID
//}
