import Foundation
@_exported import JSONSchema


/// A protocol representing a language model (LLM), which extends the `Step` protocol.
///
/// `Model` defines a system prompt and can utilize a set of tools to assist in its operations.
public protocol Model: Step {
    
    /// The system prompt used by the model.
    ///
    /// - Note: This prompt serves as the base context for the model's behavior.
    var systemPrompt: String { get }
    
    /// A collection of tools available to the model for assisting in its operations.
    ///
    /// - Note: Tools can be used by the model to perform specialized tasks.
    var tools: [any Tool] { get }
}
