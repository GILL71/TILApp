import Vapor

public func sockets(_ websockets: NIOWebSocketServer) {
    websockets.get("echo-test") { ws, req in
        print("ws connnected")
        
        ws.onText { ws, text in
            print("ws received: \(text)")
            ws.send("echo - \(text)")
        }
    }
    
    websockets.get("listen", TrackingSession.parameter) { ws, req in
        print("socket listen")
        let session = try req.parameters.next(TrackingSession.self)
        guard sessionManager.sessions[session] != nil else {
            ws.close()
            return
        }
        sessionManager.add(listener: ws, to: session)
    }
}

