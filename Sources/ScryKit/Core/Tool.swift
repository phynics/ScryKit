import Foundation
@_exported import JSONSchema

/// A protocol that defines a tool with input, output, and functionality.
///
/// `Tool` provides a standardized interface for tools that operate on specific input types
/// to produce specific output types asynchronously.
public protocol Tool: Identifiable, Step where Input: Codable, Output: Codable & CustomStringConvertible {
    
    /// A unique name identifying the tool.
    ///
    /// - Note: The `name` should be unique across all tools to avoid conflicts.
    var name: String { get }
    
    /// A description of what the tool does.
    ///
    /// - Note: Use this property to provide detailed information about the tool's purpose and functionality.
    var description: String { get }
    
    /// The JSON schema defining the structure of the tool's input and output.
    ///
    /// - Note: This schema ensures the tool's input and output adhere to a predefined format.
    var parameters: JSONSchema { get }
    
    /// Detailed guide providing comprehensive information about how to use the tool.
    ///
    /// - Note:
    ///   The `guide` should include the following sections:
    ///
    ///   1. **Tool Name**:
    ///      - The unique name of the tool.
    ///      - This name should be descriptive and clearly indicate the tool's purpose.
    ///
    ///   2. **Description**:
    ///      - A concise explanation of the tool's purpose and functionality.
    ///      - This section should help users understand what the tool does at a high level.
    ///
    ///   3. **Parameters**:
    ///      - A list of all input parameters required or optional for using the tool.
    ///      - For each parameter:
    ///        - **Name**: The parameter name.
    ///        - **Type**: The data type (e.g., `String`, `Int`).
    ///        - **Description**: A short description of the parameter's role.
    ///        - **Requirements**: Any constraints, such as valid ranges or allowed values.
    ///
    ///   4. **Usage**:
    ///      - Instructions or guidelines for using the tool effectively.
    ///      - This section should include any constraints, best practices, and common pitfalls.
    ///      - For example, explain how to handle invalid inputs or edge cases.
    ///
    ///   5. **Examples**:
    ///      - Provide practical examples demonstrating how to use the tool in real scenarios.
    ///      - Examples should include valid inputs and expected outputs, formatted as code snippets.
    ///
    ///   Here is an example of what the `guide` might look like:
    ///   ```markdown
    ///   # Tool Name
    ///   ExampleTool
    ///   function_name: `name`
    ///
    ///   ## Description
    ///   This tool calculates the length of a string.
    ///
    ///   ## Parameters
    ///   - `input`: The string whose length will be calculated.
    ///     - **Type**: `String`
    ///     - **Description**: The input text to process.
    ///     - **Requirements**: Must not be empty or null.
    ///
    ///   ## Usage
    ///   - Input strings must be UTF-8 encoded.
    ///   - Ensure the string contains at least one character.
    ///   - Avoid using strings containing unsupported characters.
    ///
    ///   ## Examples
    ///   ### Basic Usage
    ///   ```xml
    ///   <example_tool>
    ///   <input>Hello, world!</input>
    ///   </example_tool>
    ///   ```
    ///
    ///   ### Edge Case
    ///   ```xml
    ///   <example_tool>
    ///   <input> </input> <!-- Invalid: whitespace-only string -->
    ///   </example_tool>
    ///   ```
    ///   ```
    var guide: String? { get }
}

extension Tool {
    
    public var id: String { name }
    
    public func call(_ arguments: any Encodable) async throws -> String {
        do {
            let jsonData = try JSONEncoder().encode(arguments)
            let args: Self.Input = try JSONDecoder().decode(
                Input.self,
                from: jsonData
            )
            let result = try await run(args)
            return "\(result)"
        } catch {
            return "[\(name)] has Error: \(error)"
        }
    }
    
    public func call(data: Data) async throws -> String {
        do {
            let args: Self.Input = try JSONDecoder().decode(
                Input.self,
                from: data
            )
            let result = try await run(args)
            return "\(result)"
        } catch {
            return "[\(name)] has Error: \(error)"
        }
    }
}

/// Errors that can occur during tool execution.
public enum ToolError: Error {
    
    /// Required parameters are missing.
    case missingParameters([String])
    
    /// Parameters are invalid.
    case invalidParameters(String)
    
    /// Tool execution failed.
    case executionFailed(String)
    
    /// A localized description of the error.
    public var localizedDescription: String {
        switch self {
        case .missingParameters(let params):
            return "Missing required parameters: \(params.joined(separator: ", "))"
        case .invalidParameters(let message):
            return "Invalid parameters: \(message)"
        case .executionFailed(let message):
            return "Execution failed: \(message)"
        }
    }
}
