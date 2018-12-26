import Vapor
import WebSocket

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyond a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
final class TrackingSessionManager {
    private(set) var sessions: LockedDictionary<TrackingSession, [WebSocket]> = [:]
    
    func createTrackingSession(for request: Request)
        -> Future<TrackingSession> {
            print("session created")
            return wordKey(with: request)
                .flatMap(to: TrackingSession.self) { [unowned self] key in
                    let session = TrackingSession(id: key)
                    guard self.sessions[session] == nil else {
                        return self.createTrackingSession(for: request)
                    }
                    self.sessions[session] = []
                    return Future.map(on: request) { session }
            }
    }
    
    func update(_ message: Message,
                for session: TrackingSession) {
        guard let listeners = sessions[session] else {
            return
        }
        
        listeners.forEach { ws in
            ws.send(message)
        }
    }
    
    func close(_ session: TrackingSession) {
        guard let listeners = sessions[session] else {
            return
        }
        
        listeners.forEach { ws in
            ws.close()
        }
        
        sessions[session] = nil
    }
    
    func add(listener: WebSocket, to session: TrackingSession) {
        // 1
        guard var listeners = sessions[session] else {
            return
        }
        
        listeners.append(listener)
        sessions[session] = listeners
        
        // 2
        listener.onClose.always { [weak self, weak listener] in
            guard let listener = listener else {
                return
            }
            
            self?.remove(listener: listener, from: session)
        }
    }
    
    func remove(listener: WebSocket,
                from session: TrackingSession) {
        // 3
        guard var listeners = sessions[session] else {
            return
        }
        
        listeners = listeners.filter { $0 !== listener }
        sessions[session] = listeners
    }
}


//curl -w "%{response_code}\n" \
//-d '{"latitude": 37.331, "longitude": -122.031}' \
//-H "Content-Type: application/json" -X POST \
//http://localhost:8080/update/crowd.trade.flower

