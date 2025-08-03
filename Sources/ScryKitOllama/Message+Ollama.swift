import ScryKit
import Ollama

// MARK: - Conversion Extensions

extension Message {
    /// Converts to an Ollama Chat.Message
    public func toOllamaMessage() -> Ollama.Chat.Message {
        let content: String
        if let name {
            content = "\(name): \(self.content)"
        } else {
            content = self.content
        }
        
        switch self.role {
        case .system:
            return .system(content)
        case .user:
            return .user(content)
        case .assistant:
            return .assistant(content)
        case .toolResult:
            return .tool(content)
        }
    }
    
    /// Creates a Message from an Ollama Chat.Message
    public init(ollamaMessage: Ollama.Chat.Message) {
        let role: Message.Role
        switch ollamaMessage.role {
        case .system:
            role = .system
        case .user:
            role = .user
        case .assistant:
            role = .assistant
        case .tool:
            role = .toolResult
        }
        self.init(role: role,
                  content: ollamaMessage.content,
                  name: nil)
    }
}

// MARK: - Convenience Initializers

extension Message {
    /// Creates a Message from an Ollama Chat.Message
    public static func from(_ ollamaMessage: Ollama.Chat.Message) -> Message {
        return Message(ollamaMessage: ollamaMessage)
    }
}
