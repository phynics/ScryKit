// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScryKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "ScryKit",
            targets: ["ScryKit"]),
        .library(
            name: "ScryModels",
            targets: ["ScryModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kevinhermawan/swift-json-schema.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/kevinhermawan/swift-llm-chat-openai.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/loopwork/ollama-swift.git", .upToNextMajor(from: "1.8.0"))
    ],
    targets: [
        .target(
            name: "ScryKit",
            dependencies: [
                .product(name: "JSONSchema", package: "swift-json-schema"),
            ]
        ),
        .target(
            name: "ScryModels",
            dependencies: [
                "ScryKit",
                .product(name: "LLMChatOpenAI", package: "swift-llm-chat-openai"),
                .product(name: "Ollama", package: "ollama-swift")
            ]
        ),
        .testTarget(
            name: "ScryKitTests",
            dependencies: ["ScryKit"]
        ),
    ]
)
