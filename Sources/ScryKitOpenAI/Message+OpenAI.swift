import LLMChatOpenAI
import ScryKit

// MARK: - Conversion Extensions

extension Message {
    /// Converts to an OpenAI ChatMessage
    public func toOpenAIChatMessage() -> ChatMessage {
        let role: ChatMessage.Role
        switch self.role {
        case .system:
            role = .system
        case .user:
            role = .user
        case .assistant:
            role = .assistant
        case .tool:
            // OpenAI doesn't have a specific tool role, so we'll treat it as assistant
            role = .assistant
        }
        
        return ChatMessage(role: role, content: self.content, name: self.name)
    }
    
    /// Creates a Message from an OpenAI ChatMessage
    public init(openAIChatMessage: ChatMessage) {
        let role: Role
        switch openAIChatMessage.role {
        case .system:
            role = .system
        case .user:
            role = .user
        case .assistant:
            role = .assistant
        }
        
        // Extract text content from the array of content items
        var content = ""
        for item in openAIChatMessage.content {
            if case .text(let text) = item {
                content += text
            }
        }
        
        self.init(role: role, content: content, name: nil)
    }
}

// MARK: - Convenience Initializers

extension Message {
    /// Creates a Message from an OpenAI ChatMessage
    public static func from(_ openAIChatMessage: ChatMessage) -> Message {
        return Message(openAIChatMessage: openAIChatMessage)
    }
}
