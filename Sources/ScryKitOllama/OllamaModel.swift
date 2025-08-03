import Foundation
import ScryKit
import Ollama


public struct OllamaModel<Output: Sendable>: ScryKit.Model {
    
    private let client: Ollama.Client
    
    public let tools: [any ScryKit.Tool]
    
    /// The system prompt that provides initial context
    public let systemPrompt: String
    public let configuration: OllamaModelConfiguration
    
    public let responseFormat: JSONSchema?
    
    @MainActor
    public init(
        urlSession: URLSession = .init(configuration: .default),
        configuration: OllamaModelConfiguration,
        responseFormat: JSONSchema? = nil,
        tools: [any ScryKit.Tool] = [],
        systemPrompt: ([any ScryKit.Tool]) -> String
    ) where Output == String {
        let initialSystemPrompt = systemPrompt(tools)
        self.configuration = configuration
        self.tools = tools
        self.systemPrompt = initialSystemPrompt
        self.responseFormat = responseFormat
        
        self.client = Ollama.Client(session: urlSession, host: configuration.endpoint)
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
            let toolCards: [any ToolProtocol] = tools.map {
                ToolCard(internalTool: $0)
            }
            
            let formatValue: Value?
            if let responseFormat {
                formatValue = try .init(responseFormat)
            } else {
                formatValue = nil
            }
           
            let response = try  await client.chat(model: configuration.model,
                                                  messages: ollamaMessages,
                                                  options: nil,
                                                  template: nil,
                                                  format: formatValue,
                                                  tools: toolCards,
                                                  think: configuration.think,
                                                  keepAlive: .default)
            
            // Convert response back to ScryKit.Message for tool handling
            let responseMessage = ScryKit.Message(ollamaMessage: response.message)
            var messages = input
            messages.append(responseMessage)
            
            let details = Message.Details.init(modelName: response.model.model,
                                               thinkingTrace: response.message.thinking,
                                               additional: [:])
            
            if let toolCalls = response.message.toolCalls, !toolCalls.isEmpty {
                return .assistantToolCall(response.message.content,
                                          toolCalls: try handleToolCalls(toolCalls),
                                          details: details)
            } else {
                return .assistant(response.message.content, details: details)
            }
        } catch {
            throw OllamaError.unknownError(error)
        }
    }
    
    private func handleToolCalls(_ calls: [Ollama.Chat.Message.ToolCall]) throws -> [String: Data] {
        var result: [String: Data] = [:]
        
        for toolCall in calls {
            result[toolCall.function.name] = try JSONEncoder().encode(toolCall.function.arguments)
        }
        
        return result
    }
}

public enum OllamaError: Error {
    case invalidModelName
    case failedToolConversion
    case failedToolParameters
    case unknownError(Error)
}
