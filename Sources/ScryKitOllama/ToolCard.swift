import ScryKit
import Ollama

struct ToolCard {
    private let internalTool: any ScryKit.Tool
    
    var name: String { internalTool.name }
    var description: String { internalTool.description }
    var parameters: JSONSchema { internalTool.parameters }
    var guide: String? { internalTool.guide }
    
    init(internalTool: any ScryKit.Tool) {
        self.internalTool = internalTool
    }
}
extension ToolCard: ToolProtocol {
    /// ```swift
    /// var schema: [String: Value] {
    ///     [
    ///         "type: "function",
    ///         "function": [
    ///             "name": "get_current_weather",
    ///             "description": "Get the current weather for a location",
    ///             "parameters": [
    ///                 "type": "object",
    ///                 "properties": [
    ///                     "location": [
    ///                         "type": "string",
    ///                         "description": "The location to get the weather for, e.g. San Francisco, CA"
    ///                     ],
    ///                     "format": [
    ///                         "type": "string",
    ///                         "description": "The format to return the weather in, e.g. 'celsius' or 'fahrenheit'",
    ///                         "enum": ["celsius", "fahrenheit"]
    ///                     ]
    ///                 ],
    ///                 "required": ["location", "format"]
    ///             ]
    ///         ]
    ///     ]
    /// }
    /// ```
    var schema: any Codable & Sendable {
        Value.object([
            "type": "function",
            "function": [
                "name": .string(name),
                "description": .string(description),
                "parameters": (try? Value(parameters)) ?? Value.array([])
            ]
        ])
    }
}
