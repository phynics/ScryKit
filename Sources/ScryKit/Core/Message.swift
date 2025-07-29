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
        case tool
    }
    
    /// The role of the message sender
    public let role: Role
    
    /// The content of the message
    public let content: String
    
    /// Optional name for the participant
    public let name: String?
    
    /// Creates a new message
    public init(role: Role, content: String, name: String? = nil) {
        self.role = role
        self.content = content
        self.name = name
    }
    
    /// Creates a system message
    public static func system(_ content: String, name: String? = nil) -> Message {
        return Message(role: .system, content: content, name: name)
    }
    
    /// Creates a user message
    public static func user(_ content: String, name: String? = nil) -> Message {
        return Message(role: .user, content: content, name: name)
    }
    
    /// Creates an assistant message
    public static func assistant(_ content: String, name: String? = nil) -> Message {
        return Message(role: .assistant, content: content, name: name)
    }
    
    /// Creates a tool message
    public static func tool(_ content: String, name: String? = nil) -> Message {
        return Message(role: .tool, content: content, name: name)
    }
}
