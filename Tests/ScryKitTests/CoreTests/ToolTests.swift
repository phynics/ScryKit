import Testing
import ScryKit

// MARK: - Tool Tests

@Test("Tool should have correct properties")
func testToolProperties() {
    let tool = TestTool()
    #expect(tool.name == "test_tool")
    #expect(tool.description == "A test tool")
    #expect(tool.id == "test_tool")
    #expect(tool.guide == "Test tool guide")
}

@Test("Tool should process input correctly")
func testToolProcessing() async throws {
    let tool = TestTool()
    let input = TestTool.Input(value: "test input")
    let result = try await tool.run(input)
    #expect(result.result == "Processed: test input")
}

@Test("Tool should handle call with encodable arguments")
func testToolCallWithEncodable() async throws {
    let tool = TestTool()
    let input = TestTool.Input(value: "test input")
    let result = try await tool.call(input)
    #expect(result == "Tool output: Processed: test input")
}

@Test("Tool should handle call with JSON data")
func testToolCallWithJSONData() async throws {
    let tool = TestTool()
    let jsonString = """
    {
        "value": "test input"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    
    let result = try await tool.call(data: jsonData)
    #expect(result == "Tool output: Processed: test input")
}

@Test("Tool should handle call errors")
func testToolCallError() async throws {
    let tool = ErrorTool()
    let input = ErrorTool.Input(value: "test")
    
    let result = try await tool.call(input)
    #expect(result.contains("[error_tool] has Error:"))
    #expect(result.contains("Tool execution failed"))
}
