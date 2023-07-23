import Foundation

struct Config: Decodable {
    struct Gitlab: Decodable {
        let projectId: String
        let gitlabAccessToken: String
        let assigneeId: String
        let reviewerIds: String?
    }
    
    struct Jira: Decodable {
        let jiraUsername: String
        let jiraAccessToken: String
        
        var base64Auth: String {
            Data("\(jiraUsername):\(jiraAccessToken)".utf8).base64EncodedString()
        }
    }
    
    let gitlab: Gitlab
    let jira: Jira?
}
