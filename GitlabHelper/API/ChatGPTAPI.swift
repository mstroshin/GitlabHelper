import Foundation

final class ChatGPTAPI {
    private let baseURL = "https://api.openai.com/v1"
    private let decoder = JSONDecoder()
    private let config: Config.ChatGPT
    
    init(config: Config.ChatGPT) {
        self.config = config
    }
    
    func send(message: String) async throws -> String {
        let endpoint = "\(baseURL)/chat/completions"
        
        let requestData = CompletionRequestData(
            model: .model35,
            messages: [
                .init(role: .system, content: "You are a merge request describer"),
                .init(role: .user, content: message)
            ]
        )
        
        // Create the request URL
        guard let requestUrl = URL(string: endpoint) else {
            throw "Invalid request URL"
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestData)
        
        let response = try await URLSession.shared.data(for: request)
        let responseDataObject = try decoder.decode(CompletionResponseData.self, from: response.0)
        
        let answer = responseDataObject.choices.reduce("") { partialResult, choice in
            partialResult + choice.message.content
        }
        
        return answer
    }
}

private struct Message: Codable {
    enum Role: String, Codable {
        case system
        case user
        case assistant
        case function
    }
    
    let role: Role
    let content: String
}

private struct CompletionRequestData: Encodable {
    enum Model: String, Encodable {
        case model35 = "gpt-3.5-turbo"
    }
    
    let model: Model
    let messages: [Message]
}

private struct CompletionResponseData: Decodable {
    struct Choice: Decodable {
        let message: Message
    }
    
    let choices: [Choice]
}
