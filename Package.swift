// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScryKit",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(
            name: "ScryKit",
            targets: ["ScryKit"]),
        .library(
            name: "ScryKitOllama",
            targets: ["ScryKitOllama"]),
        .library(
            name: "ScryKitOpenAI",
            targets: ["ScryKitOllama"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kevinhermawan/swift-json-schema.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/kevinhermawan/swift-llm-chat-openai.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/loopwork/ollama-swift.git", .upToNextMajor(from: "1.8.0")),
        .package(url: "https://github.com/1amageek/OpenFoundationModels.git", branch: "main")
    ],
    targets: [
        .target(
            name: "ScryKit",
            dependencies: [
                .product(name: "JSONSchema", package: "swift-json-schema"),
                .product(name: "OpenFoundationModels", package: "OpenFoundationModels"),
                .product(name: "OpenFoundationModelsMacros", package: "OpenFoundationModels")
            ]
        ),
        .target(
            name: "ScryKitOllama",
            dependencies: [
                "ScryKit",
                .product(name: "Ollama", package: "ollama-swift"),
            ]
        ),
        .target(
            name: "ScryKitOpenAI",
            dependencies: [
                "ScryKit",
                .product(name: "LLMChatOpenAI", package: "swift-llm-chat-openai"),
            ]
        ),
        .testTarget(
            name: "ScryKitTests",
            dependencies: ["ScryKit"]
        ),
    ]
)
