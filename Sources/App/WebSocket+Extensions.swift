import Vapor
import WebSocket
import Foundation

extension WebSocket {
    func send(_ message: Message) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(message) else {
            return
        }
        send(data)
    }
}

