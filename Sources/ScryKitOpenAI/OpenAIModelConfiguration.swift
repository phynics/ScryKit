import Foundation
import JSONSchema
import ScryKit
import LLMChatOpenAI

extension OpenAIModel {
    public struct OpenAIModelConfiguration {
        public let model: String
        public let endpoint: URL?
        public let apiKey: String
        public let options: ChatOptions?
        
        public init(model: String = "gpt-4o-mini",
                    endpoint: URL? = nil,
                    apiKey: String,
                    options: ChatOptions? = nil) {
            self.model = model
            self.endpoint = endpoint
            self.apiKey = apiKey
            self.options = nil
        }
    }
}

extension OpenAIModel.OpenAIModelConfiguration: ModelConfiguration {
    public var parameters: [String : String] {
        let encoder = JSONEncoder()
        
        let options: String?
        if let selfOptions = self.options,
           let encodedData = try? encoder.encode(selfOptions) {
            options = String(data: encodedData, encoding: .utf8)
        } else {
            options = nil
        }
        
        return [
            "model": model,
            "apiKey": apiKey,
            "endpoint": endpoint?.absoluteString,
            "options": options
        ]
            .compactMapValues(\.self)
    }
}
