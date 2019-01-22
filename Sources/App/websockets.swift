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
        if req.http.headers.contains(name: "AuthToken") {
            let httpName = HTTPHeaderName("AuthToken")
            req.http.headers.firstValue(name: httpName)
        }
        
//        try req.content.decode(User.self).flatMap(to: User.self) { user in
//            print(user.username)
//            return user.create(on: req)
//        }
        
        //try req.content.decode(User.self).create(on: req)//.flatMap { user in
//            print(user.username)
//            return
//        })
        
    }
}

