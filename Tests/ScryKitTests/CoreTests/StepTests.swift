import Testing
import ScryKit

@Suite("StepTests")
struct StepTests {
    @Test("EmptyStep should pass through input")
    func testEmptyStep() async throws {
        let step = EmptyStep<String>()
        let input = "test input"
        let result = try await step.run(input)
        #expect(result == input)
    }
    
    @Test("SimpleStep should process input")
    func testSimpleStep() async throws {
        let step = SimpleStep()
        let input = "test"
        let result = try await step.run(input)
        #expect(result == "Processed: test")
    }
    
    @Test("ErrorStep should throw error")
    func testErrorStep() async throws {
        let step = ErrorStep()
        let input = "test"
        
        do {
            _ = try await step.run(input)
            #expect(Bool(false), "Expected error to be thrown")
        } catch let error as TestError {
            #expect(error.message == "Step failed")
        } catch {
            #expect(Bool(false), "Unexpected error type: \(error)")
        }
    }
}
