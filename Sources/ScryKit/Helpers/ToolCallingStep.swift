import Foundation

public struct ToolCallingStep<BackingModel: Model>: Step {
    public typealias ToolCallConfirmation = @Sendable (_ toolName: String,
                                                       _ parameters: Data) async -> Bool
    let model: BackingModel
    let tools: [any Tool]
    let confirmToolCall: ToolCallConfirmation?
    
    public func run(_ input: [Message]) async throws -> [Message] {
        let response = try await model.run(input)
        assert(response.role == .assistant)
        
        guard let toolCalls = response.toolCalls, !toolCalls.isEmpty else {
            return input + [response]
        }
        
        var toolResults: [Message] = []
        
        for toolCall in toolCalls {
            let matchingTool = tools.first { tool in
                tool.name == toolCall.key
            }
            
            let confirmToolUse: Bool
            
            if let confirmToolCall {
                confirmToolUse = await confirmToolCall(toolCall.key, toolCall.value)
            } else {
                confirmToolUse = true
            }
            
            guard confirmToolUse else {
                continue
            }
            
            guard let result = try await matchingTool?.call(data: toolCall.value) else {
                continue
            }
            
            toolResults.append(.toolResult(result, toolName: toolCall.key))
        }
        
        return try await self.run(input + [response] + toolResults)
    }
}

extension Model {
    public func withToolCalling(_ tools: [any Tool],
                                confirmation: ToolCallingStep<Self>.ToolCallConfirmation? = nil) -> ToolCallingStep<Self> {
        .init(model: self,
              tools: tools,
              confirmToolCall: confirmation)
    }
}
