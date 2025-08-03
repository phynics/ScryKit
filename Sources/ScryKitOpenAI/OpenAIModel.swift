//
//  OpenAIModel.swift
//  ScryKit
//
//  Created by Norikazu Muramoto on 2025/01/13.
//

import Foundation
import ScryKit
import LLMChatOpenAI
import RegexBuilder

/// A concrete implementation of the Model protocol using LLMChatOpenAI.
public struct OpenAIModel<Output: Sendable>: ScryKit.Model {
    /// An array of tools available to the model
    public let tools: [any Tool]
    
    public let configuration: OpenAIModelConfiguration
    
    /// The system prompt that provides initial context
    public let systemPrompt: String
    
    /// Options for chat completion
    private let options: ChatOptions
    
    /// The LLMChatOpenAI client instance
    private let client: LLMChatOpenAI
    
    /// Response parser for converting JSON to Output type
    private let responseParser: @Sendable (String) throws -> Output
    
    /// Creates a new instance of OpenAIModel for text output
    public init(
        configuration: OpenAIModelConfiguration,
        tools: [any Tool] = [],
        systemPrompt: ([any Tool]) -> String
    ) where Output == String {
        let initialSystemPrompt = systemPrompt(tools)
        
        // Configure tools and options
        let initialOptions: ChatOptions
        if tools.isEmpty {
            initialOptions = configuration.options ?? ChatOptions()
        } else {
            let toolOptions = tools.map { tool in
                ChatOptions.Tool(
                    type: "function",
                    function: .init(
                        name: tool.name,
                        description: tool.description,
                        parameters: tool.parameters
                    )
                )
            }
            
            initialOptions = ChatOptions(
                frequencyPenalty: configuration.options?.frequencyPenalty,
                logitBias: configuration.options?.logitBias,
                topLogprobs: configuration.options?.topLogprobs,
                maxCompletionTokens: configuration.options?.maxCompletionTokens,
                n: configuration.options?.n,
                presencePenalty: configuration.options?.presencePenalty,
                responseFormat: configuration.options?.responseFormat,
                seed: configuration.options?.seed,
                stop: configuration.options?.stop,
                temperature: configuration.options?.temperature,
                topP: configuration.options?.topP,
                tools: toolOptions,
                toolChoice: configuration.options?.toolChoice,
                user: configuration.options?.user
            )
        }
        
        self.options = initialOptions
        self.configuration = configuration
        self.tools = tools
        self.systemPrompt = initialSystemPrompt
        self.client = LLMChatOpenAI(apiKey: configuration.apiKey, endpoint: configuration.endpoint)
        self.responseParser = { $0 }
    }
    
    /// Creates a new instance of OpenAIModel with a Codable output type
    public init(
        configuration: OpenAIModelConfiguration,
        schema: JSONSchema,
        tools: [any Tool] = [],
        systemPrompt: ([any Tool]) -> String
    ) where Output: Codable {
        let initialSystemPrompt = systemPrompt(tools)
        
        // Configure response format with schema
        let schemaFormat = ChatOptions.ResponseFormat(
            type: .jsonSchema,
            jsonSchema: .init(
                name: "response_schema",
                description: "Response format schema",
                schema: schema,
                strict: true
            )
        )
        
        // Configure tools and options
        let toolOptions = tools.map { tool in
            ChatOptions.Tool(
                type: "function",
                function: .init(
                    name: tool.name,
                    description: tool.description,
                    parameters: tool.parameters
                )
            )
        }
        
        let initialOptions = ChatOptions(
            frequencyPenalty: configuration.options?.frequencyPenalty,
            logitBias: configuration.options?.logitBias,
            topLogprobs: configuration.options?.topLogprobs,
            maxCompletionTokens: configuration.options?.maxCompletionTokens,
            n: configuration.options?.n,
            presencePenalty: configuration.options?.presencePenalty,
            responseFormat: configuration.options?.responseFormat,
            seed: configuration.options?.seed,
            stop: configuration.options?.stop,
            temperature: configuration.options?.temperature,
            topP: configuration.options?.topP,
            tools: toolOptions,
            toolChoice: configuration.options?.toolChoice,
            user: configuration.options?.user
        )
        
        self.options = initialOptions
        self.configuration = configuration
        self.tools = tools
        self.systemPrompt = initialSystemPrompt
        self.client = LLMChatOpenAI(apiKey: configuration.apiKey, endpoint: configuration.endpoint)
        self.responseParser = { jsonString in
            guard let data = jsonString.data(using: .utf8) else {
                throw OpenAIModelError.invalidResponse
            }
            return try JSONDecoder().decode(Output.self, from: data)
        }
    }
    
    /// Executes the model with the provided input messages
    public func run(_ input: [ScryKit.Message]) async throws -> ScryKit.Message {
        // Convert ScryKit.Messages to ChatMessages
        var chatMessages = input.map { $0.toOpenAIChatMessage() }
        
        // Add system prompt if not present
        if !input.contains(where: { $0.role == .system }) {
            chatMessages.insert(Message.system(systemPrompt).toOpenAIChatMessage(), at: 0)
        }
        
        do {
            let response = try await client.send(
                model: configuration.model,
                messages: chatMessages,
                options: options
            )
            
            if let toolCalls = response.choices.first?.message.toolCalls {
                var results: [String] = []
                for toolCall in toolCalls {
                    if let tool = tools.first(where: { $0.name == toolCall.function.name }) {
                        if let argumentsData = toolCall.function.arguments.data(using: .utf8) {
                            let result = try await tool.call(data: argumentsData)
                            results.append(result)
                        }
                    }
                }
                return try responseParser(results.joined(separator: "\n"))
            }
            
            guard let message = response.choices.first else {
                throw OpenAIModelError.noContent
            }
            
            guard let firstMessageOption = response.choices.first,
                  let messageContent = firstMessageOption.message.content else {
                
                guard let refusalReason = message.message.refusal else {
                    throw OpenAIModelError.noContent
                }
                
                throw OpenAIModelError.modelRefused(refusalReason)
            }
            
            let thinkingRegex = Regex {
                Optionally {
                    ChoiceOf {
                        "<think>"
                        Capture {
                            ZeroOrMore { .any }
                        }
                        "</think>"
                    }
                }
                
                Capture {
                    ZeroOrMore { .any }
                }
            }
            
            let (thinkingTrace, remainingMessage) = try parseMessageContent(messageContent)
            
            let details: Message.Details = .init(modelName: response.model,
                                                 thinkingTrace: thinkingTrace,
                                                 additional: [:])
            
            return try responseParser(remainingMessage)
        } catch let error as LLMChatOpenAIError {
            throw error
        } catch let error as OpenAIModelError {
            throw error
        } catch {
            throw LLMChatOpenAIError.networkError(error)
        }
    }
    
    func parseMessageContent(_ messageContent: String) throws -> (thinking: String?, content: String) {
        let thinkingBlockRegex = Regex {
            ChoiceOf {
                "<think>"
                "<thinking>"
            }
            Capture {
                ZeroOrMore { .any }
            }
            ChoiceOf {
                "</think>"
                "</thinking>"
            }
        }
        
        let finalRegex = Regex {
            Optionally {
                thinkingBlockRegex
            }
            Capture {
                ZeroOrMore { .any }
            }
        }
        
        if let match = try finalRegex.firstMatch(in: messageContent) {
            let (wholeMatch, thinking, content) = match.output
            
            switch match.output {
            case let (_, .some(thinking), content):
                return (thinking: String(thinking), content: String(content))
            case let (_, .none, content):
                return (thinking: .none, content: String(content))
            }
        }
        
        return (thinking: nil, content: messageContent)
    }
}

/// Errors specific to OpenAIModel
public enum OpenAIModelError: Error {
    case invalidResponse
    case noContent
    case modelRefused(String)
}

// MARK: - Type Safe Response Extensions

extension OpenAIModel where Output: Codable {
    /// Creates a new instance with updated response schema
    public func withResponseSchema(_ schema: JSONSchema) -> Self {
        let schemaFormat = ChatOptions.ResponseFormat(
            type: .jsonSchema,
            jsonSchema: .init(
                name: "response_schema",
                description: "Response format schema",
                schema: schema,
                strict: true
            )
        )
        
        let newOptions = ChatOptions(
            frequencyPenalty: options.frequencyPenalty,
            logitBias: options.logitBias,
            topLogprobs: options.topLogprobs,
            maxCompletionTokens: options.maxCompletionTokens,
            n: options.n,
            presencePenalty: options.presencePenalty,
            responseFormat: schemaFormat,
            seed: options.seed,
            stop: options.stop,
            temperature: options.temperature,
            topP: options.topP,
            tools: options.tools,
            toolChoice: options.toolChoice,
            user: options.user
        )
        
        let newConfiguration = OpenAIModelConfiguration(model: self.configuration.model,
                                                        endpoint: self.configuration.endpoint,
                                                        apiKey: self.configuration.apiKey,
                                                        options: newOptions)
        
        return OpenAIModel(configuration: newConfiguration,
                           schema: schema,
                           tools: self.tools,
                           systemPrompt: { _ in self.systemPrompt })
    }
}
