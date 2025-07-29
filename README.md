# ScryKit

ScryKit is a Swift framework for building AI agents and workflows using language models. It provides a composable, type-safe architecture for creating intelligent applications that can process data, make decisions, and interact with external systems.

This project is a hard fork of [SwiftAgent](https://github.com/1amageek/swiftagent) by @1amageek.

## Key Features

### 🧩 Composable Architecture
- **Steps**: Basic units of work that transform input to output
- **Agents**: Higher-level abstractions that combine multiple steps
- **Tools**: Specialized steps that can be used by language models
- **Models**: Language model integrations (OpenAI, Ollama)

### 🤖 Language Model Support
- **OpenAI Compatible**: Support for OpenAI and compatible APIs
- **Ollama**: Local model inference with Ollama
- **Tool Integration**: Seamless tool calling for language models

## Installation

Add ScryKit to your Swift Package Manager dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/ScryKit.git", from: "1.0.0")
]
```
