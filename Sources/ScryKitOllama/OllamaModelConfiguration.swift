import Foundation
import JSONSchema
import ScryKit
import Ollama

public struct OllamaModelConfiguration {
    public let model: Ollama.Model.ID
    public let endpoint: URL
    public let think: Bool?
    
    public init(model: Ollama.Model.ID,
                endpoint: URL,
                think: Bool? = nil) {
        self.model = model
        self.endpoint = endpoint
        self.think = think
    }
}

extension OllamaModelConfiguration: ModelConfiguration {
    public var parameters: [String : String] {
        let think: String?
        if let selfThink = self.think {
            think = selfThink ? "true" : "false"
        } else {
            think = nil
        }
        
        return [
            "model": model.model,
            "endpoint": endpoint.absoluteString,
            "think": think
        ]
            .compactMapValues(\.self)
    }
}
