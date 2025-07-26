import Foundation
import ScryKit
import Ollama


public struct OllamaModel<Output: Sendable>: ScryKit.Model {
    public typealias Input = [Ollama.Chat.Message]
    
    private let endpoint: URL?
    private let client: Ollama.Client
    
    public let model: String
    public let think: Bool?
    public let tools: [any ScryKit.Tool]
    
    
    /// The system prompt that provides initial context
    public let systemPrompt: String
    /// Response parser for converting JSON to Output type
    private let responseParser: @Sendable (String) throws -> Output
    
    @MainActor
    public init(
        model: String,
        think: Bool? = nil,
        endpoint: URL = URL(string: "http://localhost:11484")!,
        tools: [any ScryKit.Tool] = [],
        systemPrompt: ([any ScryKit.Tool]) -> String
    ) where Output == String {
        let initialSystemPrompt = systemPrompt(tools)
        
        self.model = model
        self.think = think
        self.tools = tools
        self.systemPrompt = initialSystemPrompt
        self.endpoint = endpoint
        self.client = Ollama.Client(host: endpoint)
        self.responseParser = { $0 }
    }
    
    /// Executes the model with the provided input messages
    public func run(_ input: Input) async throws -> Output {
        var messages = input
        if !messages.contains(where: { $0.role == .system }) {
            messages.insert(.system(systemPrompt), at: 0)
        }
        
        do {
            guard let modelId = Model.ID(rawValue: model) else {
                throw OllamaError.invalidModelName
            }
            
            let toolCards: [any ToolProtocol] = tools.map {
                ToolCard(internalTool: $0)
            }
            
            let response = try  await client.chat(model: modelId,
                                                  messages: messages,
                                                  options: nil,
                                                  template: nil,
                                                  format: nil,
                                                  tools: toolCards,
                                                  think: think,
                                                  keepAlive: .default)
            messages.append(response.message)
            if let toolCalls = response.message.toolCalls {
                return try await handleToolCalls(toolCalls, messages: input)
            } else {
                return try responseParser(response.message.content)
            }
        } catch {
            throw OllamaError.unknownError(error)
        }
    }
    
    private func handleToolCalls(
        _ toolCalls: [Ollama.Chat.Message.ToolCall],
        messages: [Ollama.Chat.Message]
    ) async throws -> Output {
        var messages = messages
        for toolCall in toolCalls {
            let matchingTool = tools.first(where: { $0.name == toolCall.function.name })
            if let matchingTool {
                let arguments = toolCall.function.arguments
                let result = try await matchingTool.call(arguments)
                messages.append(.tool(result))
            }
        }
        return try await run(messages)
    }
}

public enum OllamaError: Error {
    case invalidModelName
    case failedToolConversion
    case unknownError(Error)
}
