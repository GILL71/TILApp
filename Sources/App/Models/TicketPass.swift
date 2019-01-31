import Vapor
import FluentPostgreSQL

//это то, что я в конечно итоге должен буду передать в виде attachment в письме
//пасс будет генерироваться на сервере простой функцией, которая будет принимать в качестве параметра
//email - на который должно быть отправлено письмо с ответом
//

final class TicketPass: Codable {
    var recipientEmail: String?
    var header: String?
    var text: String?
    var name: String?
    
    init(recipientEmail: String, header: String?, text: String, name: String?) {
        self.recipientEmail = recipientEmail
        self.header = header
        self.text = text
        self.name = name
    }
}

//docker run --name postgres -e POSTGRES_DB=vapor \
//-e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password \
//-p 5432:5432 -d postgres
extension TicketPass: Content {}


