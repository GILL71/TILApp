// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TILApp",
    products: [
        .library(
            name: "TILApp",
            targets: ["App"]),
        ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git",
                 from: "3.0.0"),

        // 1
        .package(url: "https://github.com/vapor/fluent-postgresql.git",
                 from: "1.0.0"),
        
        .package(url: "https://github.com/vapor/websocket.git", from: "1.0.0"),
        
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP", .upToNextMinor(from: "5.1.0")),    // add the dependency
        
                    ],
    targets: [
        // 2
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "WebSocket", "Leaf",
                                            "Authentication", "SwiftSMTP"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

//let package = Package(
//    name: "TILApp",
//    dependencies: [
//        // 💧 A server-side Swift web framework.
//        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
//
//        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
//        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0")
//    ],
//    targets: [
//        .target(name: "App", dependencies: ["FluentSQLite", "Vapor"]),
//        .target(name: "Run", dependencies: ["App"]),
//        .testTarget(name: "AppTests", dependencies: ["App"])
//    ]
//)

