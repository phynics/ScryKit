//
//  Loop.swift
//  ScryKit
//
//  Created by Norikazu Muramoto on 2025/01/21.
//


import Foundation

/// A step that repeatedly executes another step until a condition is met or indefinitely.
///
/// The `Loop` step provides two main ways of operation:
/// 1. Finite loop with a condition and maximum iterations
/// 2. Infinite loop that continues until manually stopped
///
/// Example of finite loop:
/// ```swift
/// Loop(max: 5) { input in
///     Transform { value in
///         value + 1
///     }
/// } until: {
///     Transform { value in
///         value >= 10
///     }
/// }
/// ```
///
/// Example of infinite loop:
/// ```swift
/// Loop { input in
///     WaitForInput(prompt: "Enter command: ")
///     Transform { command in
///         processCommand(command)
///     }
/// }
/// ```
public struct Loop<S: Step>: Step {
    
    /// The input type for the loop step
    public typealias Input = S.Input
    
    /// The output type for the loop step
    public typealias Output = S.Output
    
    private let maximumAttempts: Int
    
    /// The step to execute in each iteration
    private let step: @Sendable (Input) -> S
    
    /// Optional condition to check for loop termination
    private let condition: (@Sendable () -> any Step<S.Output, Bool>)?
    
    /// Create a finite loop with a maximum number of iterations and termination condition
    ///
    /// - Parameters:
    ///   - max: Maximum number of iterations
    ///   - step: The step to execute in each iteration
    ///   - condition: Condition to check for loop termination
    public init(
        maximumAttempts: Int,
        @StepBuilder step: @escaping @Sendable (Input) -> S,
        @StepBuilder until condition: @escaping @Sendable () -> any Step<S.Output, Bool>
    ) {
        precondition(maximumAttempts > 0, "Maximum iterations must be greater than 0")
        self.maximumAttempts = maximumAttempts
        self.step = step
        self.condition = condition
    }
    
    
    /// Execute the loop with the given input
    ///
    /// - Parameter input: Initial input value
    /// - Returns: Final output value
    /// - Throws:
    ///   - `LoopError.conditionNotMet` if maximum iterations reached in finite loop
    ///   - `LoopError.cancelled` if the task was cancelled
    ///   - Any error thrown by the executed step or condition
    public func run(_ input: Input) async throws -> Output {
        for iteration in 0..<maximumAttempts {
            // Check for task cancellation
            try Task.checkCancellation()
            
            // Execute the step
            let output = try await step(input).run(input)
            
            // Check termination condition
            if let condition = condition,
               try await condition().run(output) {
                return output
            }
            
            // Optional: you can add iteration tracking here
            if !Task.isCancelled {
                try await reportProgress(iteration: iteration, max: maximumAttempts)
            }
        }
        throw LoopError.conditionNotMet
        
    }
    
    /// Report progress of the loop execution
    ///
    /// This is a placeholder for progress reporting functionality.
    /// You can implement custom progress tracking by overriding this method.
    ///
    /// - Parameters:
    ///   - iteration: Current iteration number (if finite loop)
    ///   - max: Maximum iterations (if finite loop)
    private func reportProgress(iteration: Int?, max: Int?) async throws {
        // Placeholder for progress reporting
        // You can implement custom progress tracking here
    }
}

/// Errors that can occur during loop execution
public enum LoopError: Error, LocalizedError {
    /// Indicates that the maximum iterations were reached without meeting the condition
    case conditionNotMet
    
    /// Indicates that the loop was cancelled
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .conditionNotMet:
            return "Maximum iterations reached without meeting the termination condition"
        case .cancelled:
            return "Loop execution was cancelled"
        }
    }
}

// MARK: - Helper Functions

extension Loop {
    /// Create a loop with a simple boolean condition
    ///
    /// This convenience initializer allows creating a loop with a simple boolean condition
    /// rather than a full Step-based condition.
    ///
    /// Example:
    /// ```swift
    /// Loop(max: 5, step: someStep) { value in
    ///     value >= 10
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - max: Maximum number of iterations
    ///   - step: The step to execute in each iteration
    ///   - condition: Simple boolean condition for loop termination
    public init(
        maximumAttempts: Int,
        @StepBuilder step: @escaping @Sendable (Input) -> S,
        condition: @escaping @Sendable (Output) -> Bool
    ) {
        self.init(maximumAttempts: maximumAttempts, step: step) {
            Transform(transformer: condition)
        }
    }
}

// MARK: - Async Sequence Support

extension Loop: AsyncSequence where S: AsyncSequence {
    public typealias AsyncIterator = AsyncIteratorImpl
    
    public func makeAsyncIterator() -> AsyncIteratorImpl {
        AsyncIteratorImpl(loop: self)
    }
    
    public struct AsyncIteratorImpl: AsyncIteratorProtocol {
        let loop: Loop
        var current: Input?
        var iteration = 0
        
        init(loop: Loop) {
            self.loop = loop
            self.current = nil
        }
        
        public mutating func next() async throws -> Output? {
            guard let input = current else {
                return nil
            }
            guard iteration < loop.maximumAttempts else {
                return nil
            }
            
            let output = try await loop.step(input).run(input)
            if let condition = loop.condition,
               try await condition().run(output) {
                return nil
            }
            
            iteration += 1
            return output
        }
    }
}

// MARK: - Custom String Convertible

extension Loop: CustomStringConvertible {
    public var description: String {
        "Loop(maximumAttempts: \(maximumAttempts))"
    }
}

// MARK: - Custom Debug String Convertible

extension Loop: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Loop<\(S.self)>(max: \(maximumAttempts))"
    }
}
