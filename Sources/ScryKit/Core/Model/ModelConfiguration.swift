

/// A protocol for model configuration
public protocol ModelConfiguration: Sendable {
    var parameters: [String: String] { get }
}

public struct AnyModelConfiguration: ModelConfiguration {
    private let internalValue: any ModelConfiguration
    
    public var parameters: [String : String] {
        internalValue.parameters
    }
    
    public init<C: ModelConfiguration>(_ value: C) {
        self.internalValue = value
    }
}
