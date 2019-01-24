import Vapor
import FluentPostgreSQL

//это то, что я в конечно итоге должен буду передать в виде attachment в письме
//пасс будет генерироваться на сервере простой функцией, которая будет принимать в качестве параметра
//email - на который должно быть отправлено письмо с ответом
//

final class TicketPass: Codable {
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
extension TicketPass: PostgreSQLModel {}
extension TicketPass: Content {}
extension TicketPass: Parameter {}

extension TicketPass {
    // 1
    var user: Parent<TicketPass, User>? {
        // 2
        return parent(\.userID)
    }
}

extension TicketPass: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

