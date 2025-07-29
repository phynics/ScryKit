import Foundation
import ScryKit

// MARK: - Shared Test Types

struct TestError: Error {
    let message: String
}

struct TestTool: Tool {
    let name = "test_tool"
    let description = "A test tool"
    let parameters = JSONSchema.object(properties: [
        "value": .string(description: "Input value")
    ])
    let guide: String? = "Test tool guide"
    
    struct Input: Codable, Sendable {
        let value: String
    }
    
    struct Output: Codable, CustomStringConvertible, Sendable {
        let result: String
        
        var description: String {
            "Tool output: \(result)"
        }
    }
    
    func run(_ input: Input) async throws -> Output {
        Output(result: "Processed: \(input.value)")
    }
}

struct ErrorTool: Tool {
    let name = "error_tool"
    let description = "A tool that always fails"
    let parameters = JSONSchema.object(properties: [
        "value": .string(description: "Input value")
    ])
    let guide: String? = nil
    
    struct Input: Codable, Sendable {
        let value: String
    }
    
    struct Output: Codable, CustomStringConvertible, Sendable {
        let result: String
        
        var description: String {
            "Never called"
        }
    }
    
    func run(_ input: Input) async throws -> Output {
        throw TestError(message: "Tool execution failed")
    }
}

struct WeatherTool: Tool {
    let name = "get_weather"
    let description = "Get weather information for a location"
    let parameters = JSONSchema.object(properties: [
        "location": .string(description: "City name"),
        "unit": .string(description: "Temperature unit (celsius/fahrenheit)")
    ])
    let guide: String? = "Weather tool guide"
    
    struct Input: Codable, Sendable {
        let location: String
        let unit: String
    }
    
    struct Output: Codable, CustomStringConvertible, Sendable {
        let temperature: Int
        let condition: String
        let location: String
        
        var description: String {
            "Weather in \(location): \(temperature)°\(unit), \(condition)"
        }
        
        private var unit: String {
            temperature > 20 ? "C" : "F"
        }
    }
    
    func run(_ input: Input) async throws -> Output {
        // Mock weather data
        return Output(
            temperature: input.unit == "celsius" ? 22 : 72,
            condition: "Sunny",
            location: input.location
        )
    }
}

// MARK: - Mock Steps

struct SimpleStep: Step {
    typealias Input = String
    typealias Output = String
    
    func run(_ input: String) async throws -> String {
        return "Processed: \(input)"
    }
}

struct ErrorStep: Step {
    typealias Input = String
    typealias Output = String
    
    func run(_ input: String) async throws -> String {
        throw TestError(message: "Step failed")
    }
}

struct DoublingStep: Step {
    typealias Input = Int
    typealias Output = Int
    
    func run(_ input: Int) async throws -> Int {
        return input * 2
    }
}

struct SumStep: Step {
    typealias Input = (Int, Int)
    typealias Output = Int
    
    func run(_ input: (Int, Int)) async throws -> Int {
        return input.0 + input.1
    }
}

struct DelayStep: Step {
    typealias Input = String
    typealias Output = String
    
    let delay: TimeInterval
    
    init(delay: TimeInterval = 0.1) {
        self.delay = delay
    }
    
    func run(_ input: String) async throws -> String {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return "Delayed: \(input)"
    }
}

struct FastStep: Step {
    typealias Input = String
    typealias Output = String
    
    let delay: TimeInterval
    
    init(delay: TimeInterval = 0.05) {
        self.delay = delay
    }
    
    func run(_ input: String) async throws -> String {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return "Fast: \(input)"
    }
}

struct SlowStep: Step {
    typealias Input = String
    typealias Output = String
    
    let delay: TimeInterval
    
    init(delay: TimeInterval = 0.2) {
        self.delay = delay
    }
    
    func run(_ input: String) async throws -> String {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return "Slow: \(input)"
    }
}

struct StringStep: Step {
    typealias Input = String
    typealias Output = String
    
    let suffix: String
    
    init(suffix: String) {
        self.suffix = suffix
    }
    
    func run(_ input: String) async throws -> String {
        return "\(input)\(suffix)"
    }
}

struct CounterStep: Step {
    typealias Input = Int
    typealias Output = Int
    
    func run(_ input: Int) async throws -> Int {
        return input + 1
    }
}

struct LoopCondition: Step {
    typealias Input = Int
    typealias Output = Bool
    
    let maxCount: Int
    
    init(maxCount: Int) {
        self.maxCount = maxCount
    }
    
    func run(_ input: Int) async throws -> Bool {
        return input < maxCount
    }
}

struct MonitoredStep: Step {
    typealias Input = String
    typealias Output = String
    
    func run(_ input: String) async throws -> String {
        return "Monitored: \(input)"
    }
}

// MARK: - Mock Models

struct MockModel: Model {
    let systemPrompt = "You are a test assistant"
    let tools: [any Tool] = []
    
    func run(_ input: [Message]) async throws -> Message {
        return .assistant("Mock response: \(input.last?.content ?? "")")
    }
}

struct MockModelWithTools: Model {
    let systemPrompt = "You are a test assistant with tools"
    let tools: [any Tool]
    
    init(tools: [any Tool]) {
        self.tools = tools
    }
    
    func run(_ input: [Message]) async throws -> Message {
        return .assistant("Mock response with \(tools.count) tools: \(input.last?.content ?? "")")
    }
}

struct ErrorModel: Model {
    let systemPrompt = "Error model"
    let tools: [any Tool] = []
    
    func run(_ input: [Message]) async throws -> Message {
        throw TestError(message: "Model failed")
    }
}

struct PerformanceModel: Model {
    let systemPrompt = "Performance test model"
    let tools: [any Tool] = []
    
    func run(_ input: [Message]) async throws -> Message {
        // Simulate some processing time
        try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        return .system("Slow response: \(input.last?.content ?? "")")
    }
}

// MARK: - Mock Agents

struct SimpleAgent: Agent {
    var body: some Step<String, String> {
        SimpleStep()
    }
}

struct MultiStepAgent: Agent {
    var body: some Step<String, String> {
        SimpleStep()
        Transform<String, String> { input in
            "Final: \(input)"
        }
    }
}

// MARK: - Error Types

enum ValidationError: Error {
    case emptyContent
}

enum AssistantError: Error {
    case invalidQuery
} 
