import Foundation
import ScryKit
import Ollama


public struct OllamaModel<Output: Sendable>: ScryKit.Model {
    public typealias Input = [ScryKit.Message]
    public typealias Output = ScryKit.Message
    
    private let endpoint: URL?
    private let client: Ollama.Client
    
    public let model: String
    public let responseFormat: JSONSchema?
    public let think: Bool?
    public let tools: [any ScryKit.Tool]
    
    
    /// The system prompt that provides initial context
    public let systemPrompt: String
    
    @MainActor
    public init(
        model: String,
        responseFormat: JSONSchema?,
        think: Bool? = nil,
        endpoint: URL = URL(string: "http://localhost:11484")!,
        tools: [any ScryKit.Tool] = [],
        systemPrompt: ([any ScryKit.Tool]) -> String
    ) where Output == String {
        let initialSystemPrompt = systemPrompt(tools)
        
        self.model = model
        self.responseFormat = responseFormat
        self.think = think
        self.tools = tools
        self.systemPrompt = initialSystemPrompt
        self.endpoint = endpoint
        self.client = Ollama.Client(host: endpoint)
    }
    
    /// Executes the model with the provided input messages
    public func run(_ input: Input) async throws -> Message {
        // Convert ScryKit.Messages to Ollama.Chat.Messages
        var ollamaMessages = input.map { $0.toOllamaMessage() }
        
        // Add system prompt if not present
        if !input.contains(where: { $0.role == .system }) {
            ollamaMessages.insert(Message.system(systemPrompt).toOllamaMessage(), at: 0)
        }
        
        do {
            guard let modelId = Model.ID(rawValue: model) else {
                throw OllamaError.invalidModelName
            }
            
            let toolCards: [any ToolProtocol] = tools.map {
                ToolCard(internalTool: $0)
            }
            
            let response = try  await client.chat(model: modelId,
                                                  messages: ollamaMessages,
                                                  options: nil,
                                                  template: nil,
                                                  format: .init(responseFormat),
                                                  tools: toolCards,
                                                  think: think,
                                                  keepAlive: .default)
            
            // Convert response back to ScryKit.Message for tool handling
            let responseMessage = ScryKit.Message(ollamaMessage: response.message)
            var messages = input
            messages.append(responseMessage)
            
            let details = Message.Details.init(modelName: response.model.model,
                                               thinkingTrace: response.message.thinking,
                                               additional: [:])
            
            if let toolCalls = response.message.toolCalls {
                return try await handleToolCalls(toolCalls, messages: input)
            } else {
                return .assistant(response.message.content, details: details)
            }
        } catch {
            throw OllamaError.unknownError(error)
        }
    }
    
    private func handleToolCalls(
        _ toolCalls: [Ollama.Chat.Message.ToolCall],
        messages: [ScryKit.Message]
    ) async throws -> Message {
        var messages = messages
        for toolCall in toolCalls {
            let matchingTool = tools.first(where: { $0.name == toolCall.function.name })
            if let matchingTool {
                let arguments = toolCall.function.arguments
                let result = try await matchingTool.call(arguments)
                messages.append(.tool(result, name: matchingTool.name))
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
