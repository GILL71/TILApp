import Vapor

struct TrackingSession: Content, Hashable {
    let id: String
}

extension TrackingSession: Parameter {
    static func resolveParameter(_ parameter: String, on container: Container) throws -> TrackingSession {
        return .init(id: parameter)
    }
}

