import Testing
import ScryKit

// MARK: - Model Tests

@Test("Model should have required properties")
func testModelProperties() {
    let model = MockModel()
    #expect(model.systemPrompt == "You are a test assistant")
    #expect(model.tools.isEmpty)
}

@Test("Model should process input")
func testModelProcessing() async throws {
    let model = MockModel()
    let input = "test input"
    let result = try await model.run([.user(input)])
    #expect(result == .assistant("Mock response: \(input)"))
}

@Test("Model with tools should have tools")
func testModelWithTools() {
    let testTool = TestTool()
    let model = MockModelWithTools(tools: [testTool])
    #expect(model.tools.count == 1)
    #expect(model.systemPrompt == "You are a test assistant with tools")
}
