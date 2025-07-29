import Testing
import ScryKit


// MARK: - Message Tests
@Suite("Message Tests")
struct MessageTests {
    @Test("Message should create different role types")
    func testMessageRoles() {
        let systemMessage = Message.system("System prompt")
        #expect(systemMessage.role == .system)
        #expect(systemMessage.content == "System prompt")
        
        let userMessage = Message.user("Hello")
        #expect(userMessage.role == .user)
        #expect(userMessage.content == "Hello")
        
        let assistantMessage = Message.assistant("Hi there!")
        #expect(assistantMessage.role == .assistant)
        #expect(assistantMessage.content == "Hi there!")
        
        let toolMessage = Message.tool("Tool result")
        #expect(toolMessage.role == .tool)
        #expect(toolMessage.content == "Tool result")
    }
    
    @Test("Message should support named participants")
    func testMessageWithName() {
        let namedMessage = Message.user("Hello", name: "John")
        #expect(namedMessage.role == .user)
        #expect(namedMessage.content == "Hello")
        #expect(namedMessage.name == "John")
    }
}
