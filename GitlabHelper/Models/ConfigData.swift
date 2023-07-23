import Foundation

struct Config: Decodable {
    struct Gitlab: Decodable {
        let projectId: Int
        let gitlabAccessToken: String
        let assigneeId: Int
        let reviewerIds: [Int]?
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
