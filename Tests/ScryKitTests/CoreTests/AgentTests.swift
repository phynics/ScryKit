//
//  AgentTests.swift
//  ScryKit
//
//  Created by Atakan Dulker on 29.07.25.
//

import Testing
import ScryKit

// MARK: - Agent Tests

@Suite("Agent Tests")
struct AgentTEsts {
    @Test("SimpleAgent should delegate to body")
    func testSimpleAgent() async throws {
        let agent = SimpleAgent()
        let input = "test"
        let result = try await agent.run(input)
        #expect(result == "Processed: test")
    }
    
    @Test("MultiStepAgent should chain steps")
    func testMultiStepAgent() async throws {
        let agent = MultiStepAgent()
        let input = "test"
        let result = try await agent.run(input)
        #expect(result == "Final: Processed: test")
    }
}
