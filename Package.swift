// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "NISDK3",
    platforms: [
        .iOS(.v10), // Matches CocoaPods deployment target
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "NISDK3",
            targets: ["NISDK3"]
        )
    ],
    dependencies: [
        // Uncomment and add dependencies if needed
        // .package(url: "https://github.com/AFNetworking/AFNetworking.git", from: "2.3.0")
    ],
    targets: [
        .target(
            name: "NISDK3",
            path: "NISDK3/Classes",            
            resources: [
                // Uncomment if you have assets
                // .process("Assets")
            ]
            // dependencies: ["AFNetworking"] // Uncomment if required
        ),
    ]
)
