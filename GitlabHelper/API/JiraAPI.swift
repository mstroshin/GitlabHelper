import Foundation

final class JiraAPI {
    private let baseURL = "https://diftech.atlassian.net/rest/api/latest"
    private let decoder = JSONDecoder()
    private let config: Config.Jira
    
    init(config: Config.Jira) {
        self.config = config
    }
    
    func getTaskTitle(taskNumber: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/issue/\(taskNumber)?fields=summary") else {
            throw "Wrong jira url"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(config.base64Auth)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let issue = try decoder.decode(Issue.self, from: data)
        
        return issue.fields.summary
    }
    
}

private struct Issue: Decodable {
    struct Fields: Decodable {
        let summary: String
    }
    
    let fields: Fields
}
