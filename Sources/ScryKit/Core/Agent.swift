import Foundation
@_exported import JSONSchema


/// A protocol representing an agent, which acts as a composite step by combining multiple steps.
///
/// `Agent` is composed of a body that defines its behavior and operates as a higher-level abstraction
/// over individual steps.
///
/// - Note: The `Input` and `Output` types of the `Agent` match those of its `Body`.
public protocol Agent: Step where Input == Body.Input, Output == Body.Output {
    
    /// The type of the body, which must conform to `Step`.
    associatedtype Body: Step
    
    /// A builder property that defines the body of the agent.
    ///
    /// - Note: The body determines how the agent processes its input and generates its output.
    @StepBuilder var body: Self.Body { get }
}

extension Agent {
    
    /// Executes the agent's operation by delegating to its body.
    ///
    /// - Parameter input: The input for the agent.
    /// - Returns: The output produced by the agent's body.
    /// - Throws: An error if the agent's body fails to execute.
    public func run(_ input: Input) async throws -> Output {
        try await body.run(input)
    }
}




