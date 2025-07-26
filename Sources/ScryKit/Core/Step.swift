import Foundation
@_exported import JSONSchema

/// A protocol representing a single step in a process.
///
/// `Step` takes an input of a specific type and produces an output of another type asynchronously.
///
/// - Note: The input and output types must conform to both  `Sendable` to ensure
///   compatibility with serialization and concurrency.
public protocol Step<Input, Output>: Sendable {
    
    /// The type of input required by the step.
    associatedtype Input: Sendable
    
    /// The type of output produced by the step.
    associatedtype Output: Sendable
    
    /// Executes the step with the given input and produces an output asynchronously.
    ///
    /// - Parameter input: The input for the step.
    /// - Returns: The output produced by the step.
    /// - Throws: An error if the step fails to execute or the input is invalid.
    @Sendable func run(_ input: Input) async throws -> Output
}

public enum OptionalStepError: Error {
    case stepIsNil
}

/// A step that does nothing and simply passes the input as the output.
public struct EmptyStep<Input: Sendable>: Step {
    public typealias Output = Input
    
    @inlinable public init() {}
    
    public func run(_ input: Input) async throws -> Output {
        input
    }
}
