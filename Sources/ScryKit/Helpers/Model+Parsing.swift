import Foundation

extension Model {
    func parsing<TargetType: Decodable & Sendable>(_ type: TargetType.Type) async throws -> Transform<Message, TargetType?> {
        Transform { responseMessage in
            try JSONDecoder().decode(type, from: responseMessage.content.data(using: .utf8) ?? Data())
        }
    }
}
