// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "drinkdVaporServer",
    platforms: [
       .macOS(.v15),
       .iOS(.v17)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(
            url: "https://github.com/supabase/supabase-swift.git",
            from: "2.0.0"
        ),
        .package(path: "../drinkdSharedModels")

    ],
    targets: [
        .executableTarget(
            name: "drinkdVaporServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(
                    name: "Supabase", // Auth, Realtime, Postgrest, Functions, or Storage
                    package: "supabase-swift"
                ),
                .product(name: "drinkdSharedModels", package: "drinkdSharedModels")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "drinkdVaporServerTests",
            dependencies: [
                .target(name: "drinkdVaporServer"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
