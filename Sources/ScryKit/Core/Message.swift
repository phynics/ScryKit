import Foundation

/// A unified message type that can bridge different LLM provider message formats
public struct Message: Codable, Hashable, Sendable {
    /// The role of the message sender
    public enum Role: String, Codable, Hashable, CaseIterable, Sendable {
        /// A system message
        case system
        
        /// A message from the user
        case user
        
        /// A message from the AI assistant
        case assistant
        
        /// A message from a tool/function call
        case toolResult
    }
    
    /// The details of how the message was generated
    public struct Details: Codable, Hashable, Sendable {
        public let modelName: String
        public let thinkingTrace: String?
        public let additional: [String: String]
        
        public init(modelName: String, thinkingTrace: String? = nil, additional: [String: String] = [:]) {
            self.modelName = modelName
            self.thinkingTrace = thinkingTrace
            self.additional = additional
        }
    }
    
    /// The role of the message sender
    public let role: Role
    
    /// The content of the message
    public let content: String
    
    /// Optional name for the participant
    public let name: String?
    
    /// Optional tool calls from the assistant
    public let toolCalls: [String: Data]?
    
    /// Details of how the response is generated
    public let details: Details?
    
    /// Creates a new message
    public init(role: Role,
                content: String,
                name: String? = nil,
                toolCalls: [String: Data]? = nil,
                details: Details? = nil) {
        self.role = role
        self.content = content
        self.name = name
        self.toolCalls = toolCalls
        self.details = details
    }
    
    /// Creates a system message
    public static func system(_ content: String,
                              name: String? = nil,
                              details: Details? = nil) -> Message {
        return Message(role: .system, content: content, name: name, details: details)
    }
    
    /// Creates a user message
    public static func user(_ content: String,
                            name: String? = nil,
                            details: Details? = nil) -> Message {
        return Message(role: .user, content: content, name: name, details: details)
    }
    
    /// Creates an assistant message
    public static func assistant(_ content: String,
                                 name: String? = nil,
                                 details: Details? = nil) -> Message {
        return Message(role: .assistant, content: content, name: name, details: details)
    }
    
    /// Creates a tool message
    public static func toolResult(_ toolResult: String,
                                  toolName: String,
                                  details: Details? = nil) -> Message {
        return Message(role: .toolResult, content: toolResult, name: toolName, details: details)
    }
    
    /// Creates an assistant message
    public static func assistantToolCall(_ content: String,
                                         name: String? = nil,
                                         toolCalls: [String: Data],
                                         details: Details? = nil) -> Message {
        return Message(role: .assistant, content: content, name: name, toolCalls: toolCalls, details: details)
    }
}
