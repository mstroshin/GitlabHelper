import Foundation

final class GitlabAPI {
    private let baseURL = "https://gitlab.diftech.org/api/v4"
    private let decoder = JSONDecoder()
    private let config: Config.Gitlab
    
    init(config: Config.Gitlab) {
        self.config = config
    }
    
    func createMergeRequest(
        with sourceBranch: String,
        targetBranch: String,
        title: String?,
        description: String?
    ) async throws {
        let endpoint = "\(baseURL)/projects/\(config.projectId)/merge_requests"
        let title = title ?? sourceBranch
        
        let requestData = CreateMRRequestData(
            title: title,
            description: description,
            source_branch: sourceBranch,
            target_branch: targetBranch,
            assignee_id: config.assigneeId,
            reviewer_ids: config.reviewerIds,
            remove_source_branch: true
        )
        
        // Create the request URL
        guard let requestUrl = URL(string: endpoint) else {
            throw "Invalid request URL"
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.gitlabAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestData)
        
        let response = try await URLSession.shared.data(for: request)
        let responseDataObject = try decoder.decode(CreateMRResponseData.self, from: response.0)
        
        print("MR was created successful: \(responseDataObject.web_url)")
    }
    
}
