import Foundation
@_exported import JSONSchema

/// A result builder to combine steps into chains.
@resultBuilder
public struct StepBuilder {
    
    public static func buildBlock<Content>(_ content: Content) -> Content where Content: Step {
        content
    }
    
    public static func buildBlock<S1: Step, S2: Step>(_ step1: S1, _ step2: S2) -> Chain2<S1, S2> where S1.Output == S2.Input {
        Chain2(step1, step2)
    }
    
    public static func buildBlock<S1: Step, S2: Step, S3: Step>(_ step1: S1, _ step2: S2, _ step3: S3) -> Chain3<S1, S2, S3> where S1.Output == S2.Input, S2.Output == S3.Input {
        Chain3(step1, step2, step3)
    }
    
    public static func buildBlock<S1: Step, S2: Step, S3: Step, S4: Step>(_ step1: S1, _ step2: S2, _ step3: S3, _ step4: S4) -> Chain4<S1, S2, S3, S4> where S1.Output == S2.Input, S2.Output == S3.Input, S3.Output == S4.Input {
        Chain4(step1, step2, step3, step4)
    }
    
    public static func buildBlock<S1: Step, S2: Step, S3: Step, S4: Step, S5: Step>(_ step1: S1, _ step2: S2, _ step3: S3, _ step4: S4, _ step5: S5) -> Chain5<S1, S2, S3, S4, S5> where S1.Output == S2.Input, S2.Output == S3.Input, S3.Output == S4.Input, S4.Output == S5.Input {
        Chain5(step1, step2, step3, step4, step5)
    }
    
    public static func buildBlock<S1: Step, S2: Step, S3: Step, S4: Step, S5: Step, S6: Step>(_ step1: S1, _ step2: S2, _ step3: S3, _ step4: S4, _ step5: S5, _ step6: S6) -> Chain6<S1, S2, S3, S4, S5, S6> where S1.Output == S2.Input, S2.Output == S3.Input, S3.Output == S4.Input, S4.Output == S5.Input, S5.Output == S6.Input {
        Chain6(step1, step2, step3, step4, step5, step6)
    }
    
    public static func buildBlock<S1: Step, S2: Step, S3: Step, S4: Step, S5: Step, S6: Step, S7: Step>(_ step1: S1, _ step2: S2, _ step3: S3, _ step4: S4, _ step5: S5, _ step6: S6, _ step7: S7) -> Chain7<S1, S2, S3, S4, S5, S6, S7> where S1.Output == S2.Input, S2.Output == S3.Input, S3.Output == S4.Input, S4.Output == S5.Input, S5.Output == S6.Input, S6.Output == S7.Input {
        Chain7(step1, step2, step3, step4, step5, step6, step7)
    }
    
    public static func buildBlock<S1: Step, S2: Step, S3: Step, S4: Step, S5: Step, S6: Step, S7: Step, S8: Step>(_ step1: S1, _ step2: S2, _ step3: S3, _ step4: S4, _ step5: S5, _ step6: S6, _ step7: S7, _ step8: S8) -> Chain8<S1, S2, S3, S4, S5, S6, S7, S8> where S1.Output == S2.Input, S2.Output == S3.Input, S3.Output == S4.Input, S4.Output == S5.Input, S5.Output == S6.Input, S6.Output == S7.Input, S7.Output == S8.Input {
        Chain8(step1, step2, step3, step4, step5, step6, step7, step8)
    }
}
/// A structure that combines two `Step` instances and executes them sequentially.
public struct Chain2<S1: Step, S2: Step>: Step where S1.Output == S2.Input {
    public typealias Input = S1.Input
    public typealias Output = S2.Output
    
    public let step1: S1
    public let step2: S2
    
    @inlinable public init(_ step1: S1, _ step2: S2) {
        self.step1 = step1
        self.step2 = step2
    }
    
    public func run(_ input: Input) async throws -> Output {
        let intermediate = try await step1.run(input)
        return try await step2.run(intermediate)
    }
}

/// A structure that combines three `Step` instances and executes them sequentially.
public struct Chain3<S1: Step, S2: Step, S3: Step>: Step where S1.Output == S2.Input, S2.Output == S3.Input {
    public typealias Input = S1.Input
    public typealias Output = S3.Output
    
    public let step1: S1
    public let step2: S2
    public let step3: S3
    
    @inlinable public init(_ step1: S1, _ step2: S2, _ step3: S3) {
        self.step1 = step1
        self.step2 = step2
        self.step3 = step3
    }
    
    public func run(_ input: Input) async throws -> Output {
        let intermediate1 = try await step1.run(input)
        let intermediate2 = try await step2.run(intermediate1)
        return try await step3.run(intermediate2)
    }
}

/// A structure that combines four `Step` instances and executes them sequentially.
public struct Chain4<S1: Step, S2: Step, S3: Step, S4: Step>: Step where S1.Output == S2.Input, S2.Output == S3.Input, S3.Output == S4.Input {
    public typealias Input = S1.Input
    public typealias Output = S4.Output
    
    public let step1: S1
    public let step2: S2
    public let step3: S3
    public let step4: S4
    
    @inlinable public init(_ step1: S1, _ step2: S2, _ step3: S3, _ step4: S4) {
        self.step1 = step1
        self.step2 = step2
        self.step3 = step3
        self.step4 = step4
    }
    
    public func run(_ input: Input) async throws -> Output {
        let intermediate1 = try await step1.run(input)
        let intermediate2 = try await step2.run(intermediate1)
        let intermediate3 = try await step3.run(intermediate2)
        return try await step4.run(intermediate3)
    }
}

public struct Chain5<S1: Step, S2: Step, S3: Step, S4: Step, S5: Step>: Step where S1.Output == S2.Input, S2.Output == S3.Input, S3.Output == S4.Input, S4.Output == S5.Input {
    public typealias Input = S1.Input
    public typealias Output = S5.Output
    
    public let step1: S1
    public let step2: S2
    public let step3: S3
    public let step4: S4
    public let step5: S5
    
    @inlinable public init(_ step1: S1, _ step2: S2, _ step3: S3, _ step4: S4, _ step5: S5) {
        self.step1 = step1
        self.step2 = step2
        self.step3 = step3
        self.step4 = step4
        self.step5 = step5
    }
    
    public func run(_ input: Input) async throws -> Output {
        let intermediate1 = try await step1.run(input)
        let intermediate2 = try await step2.run(intermediate1)
        let intermediate3 = try await step3.run(intermediate2)
        let intermediate4 = try await step4.run(intermediate3)
        return try await step5.run(intermediate4)
    }
}

// 同様に Chain6, Chain7, Chain8 を以下のように実装します：
public struct Chain6<S1: Step, S2: Step, S3: Step, S4: Step, S5: Step, S6: Step>: Step where S1.Output == S2.Input, S2.Output == S3.Input, S3.Output == S4.Input, S4.Output == S5.Input, S5.Output == S6.Input {
    public typealias Input = S1.Input
    public typealias Output = S6.Output
    
    public let step1: S1
    public let step2: S2
    public let step3: S3
    public let step4: S4
    public let step5: S5
    public let step6: S6
    
    @inlinable public init(_ step1: S1, _ step2: S2, _ step3: S3, _ step4: S4, _ step5: S5, _ step6: S6) {
        self.step1 = step1
        self.step2 = step2
        self.step3 = step3
        self.step4 = step4
        self.step5 = step5
        self.step6 = step6
    }
    
    public func run(_ input: Input) async throws -> Output {
        let intermediate1 = try await step1.run(input)
        let intermediate2 = try await step2.run(intermediate1)
        let intermediate3 = try await step3.run(intermediate2)
        let intermediate4 = try await step4.run(intermediate3)
        let intermediate5 = try await step5.run(intermediate4)
        return try await step6.run(intermediate5)
    }
}

public struct Chain7<S1: Step, S2: Step, S3: Step, S4: Step, S5: Step, S6: Step, S7: Step>: Step where S1.Output == S2.Input, S2.Output == S3.Input, S3.Output == S4.Input, S4.Output == S5.Input, S5.Output == S6.Input, S6.Output == S7.Input {
    public typealias Input = S1.Input
    public typealias Output = S7.Output
    
    public let step1: S1
    public let step2: S2
    public let step3: S3
    public let step4: S4
    public let step5: S5
    public let step6: S6
    public let step7: S7
    
    @inlinable public init(_ step1: S1, _ step2: S2, _ step3: S3, _ step4: S4, _ step5: S5, _ step6: S6, _ step7: S7) {
        self.step1 = step1
        self.step2 = step2
        self.step3 = step3
        self.step4 = step4
        self.step5 = step5
        self.step6 = step6
        self.step7 = step7
    }
    
    public func run(_ input: Input) async throws -> Output {
        let intermediate1 = try await step1.run(input)
        let intermediate2 = try await step2.run(intermediate1)
        let intermediate3 = try await step3.run(intermediate2)
        let intermediate4 = try await step4.run(intermediate3)
        let intermediate5 = try await step5.run(intermediate4)
        let intermediate6 = try await step6.run(intermediate5)
        return try await step7.run(intermediate6)
    }
}

public struct Chain8<S1: Step, S2: Step, S3: Step, S4: Step, S5: Step, S6: Step, S7: Step, S8: Step>: Step where S1.Output == S2.Input, S2.Output == S3.Input, S3.Output == S4.Input, S4.Output == S5.Input, S5.Output == S6.Input, S6.Output == S7.Input, S7.Output == S8.Input {
    public typealias Input = S1.Input
    public typealias Output = S8.Output
    
    public let step1: S1
    public let step2: S2
    public let step3: S3
    public let step4: S4
    public let step5: S5
    public let step6: S6
    public let step7: S7
    public let step8: S8
    
    @inlinable public init(_ step1: S1, _ step2: S2, _ step3: S3, _ step4: S4, _ step5: S5, _ step6: S6, _ step7: S7, _ step8: S8) {
        self.step1 = step1
        self.step2 = step2
        self.step3 = step3
        self.step4 = step4
        self.step5 = step5
        self.step6 = step6
        self.step7 = step7
        self.step8 = step8
    }
    
    public func run(_ input: Input) async throws -> Output {
        let intermediate1 = try await step1.run(input)
        let intermediate2 = try await step2.run(intermediate1)
        let intermediate3 = try await step3.run(intermediate2)
        let intermediate4 = try await step4.run(intermediate3)
        let intermediate5 = try await step5.run(intermediate4)
        let intermediate6 = try await step6.run(intermediate5)
        let intermediate7 = try await step7.run(intermediate6)
        return try await step8.run(intermediate7)
    }
}

extension StepBuilder {
    
    public static func buildIf<Content>(_ content: Content?) -> OptionalStep<Content> where Content: Step {
        OptionalStep(content)
    }
    
    public static func buildEither<TrueContent: Step, FalseContent: Step>(
        first: TrueContent
    ) -> ConditionalStep<TrueContent, FalseContent> {
        ConditionalStep(condition: true, first: first, second: nil)
    }
    
    public static func buildEither<TrueContent: Step, FalseContent: Step>(
        second: FalseContent
    ) -> ConditionalStep<TrueContent, FalseContent> {
        ConditionalStep(condition: false, first: nil, second: second)
    }
}

public struct OptionalStep<S: Step>: Step {
    public typealias Input = S.Input
    public typealias Output = S.Output
    
    private let step: S?
    
    public init(_ step: S?) {
        self.step = step
    }
    
    public func run(_ input: Input) async throws -> Output {
        guard let step = step else {
            throw OptionalStepError.stepIsNil
        }
        return try await step.run(input)
    }
}

public struct ConditionalStep<TrueStep: Step, FalseStep: Step>: Step where TrueStep.Input == FalseStep.Input, TrueStep.Output == FalseStep.Output {
    public typealias Input = TrueStep.Input
    public typealias Output = TrueStep.Output
    
    private let condition: Bool
    private let first: TrueStep?
    private let second: FalseStep?
    
    public init(condition: Bool, first: TrueStep?, second: FalseStep?) {
        self.condition = condition
        self.first = first
        self.second = second
    }
    
    public func run(_ input: Input) async throws -> Output {
        if condition, let first = first {
            return try await first.run(input)
        } else if let second = second {
            return try await second.run(input)
        }
        throw ConditionalStepError.noStepAvailable
    }
}

public enum ConditionalStepError: Error {
    case noStepAvailable
}


/// A result builder that constructs an array of steps that can be executed in parallel.
///
/// The parallel step builder provides a declarative syntax for constructing arrays of
/// independent steps that can be executed concurrently, similar to SwiftUI's view builders.
///
/// Example usage:
/// ```swift
/// Parallel<String, Int> {
///     Transform { input in
///         Int(input) ?? 0
///     }
///     Transform { input in
///         input.count
///     }
/// }
/// ```
/// Result builder for creating arrays of steps to execute in parallel.
@resultBuilder
public struct ParallelStepBuilder {
    
    /// Builds a single step into an array.
    ///
    /// - Parameter step: The step to include
    /// - Returns: A single-element array containing the step
    public static func buildBlock<S: Step & Sendable>(_ step: S) -> [S] where S: Sendable {
        [step]
    }
    
    /// Combines multiple steps into an array using parameter packs.
    ///
    /// - Parameter steps: The steps to combine
    /// - Returns: An array containing all steps
    public static func buildBlock<each S: Step & Sendable>(_ steps: repeat each S) -> [any Step & Sendable] {
        var collection: [any Step & Sendable] = []
        repeat collection.append(each steps)
        return collection
    }
    
    /// Handles optional steps.
    ///
    /// - Parameter step: The optional step
    /// - Returns: Array containing the step if present, empty array if nil
    public static func buildOptional<S: Step & Sendable>(_ step: [S]?) -> [S] {
        step ?? []
    }
    
    /// Handles the true path of a conditional.
    ///
    /// - Parameter first: The steps to include if condition is true
    /// - Returns: The provided array of steps
    public static func buildEither<S: Step & Sendable>(first: [S]) -> [S] {
        first
    }
    
    /// Handles the false path of a conditional.
    ///
    /// - Parameter second: The steps to include if condition is false
    /// - Returns: The provided array of steps
    public static func buildEither<S: Step & Sendable>(second: [S]) -> [S] {
        second
    }
    
    /// Handles arrays of steps.
    ///
    /// - Parameter components: Array of arrays of steps
    /// - Returns: Flattened array containing all steps
    public static func buildArray<S: Step & Sendable>(_ components: [[S]]) -> [S] {
        components.flatMap { $0 }
    }
}
