import Foundation

struct CreateMRRequestData: Encodable {
    let title: String
    let source_branch: String
    let target_branch: String
    let assignee_id: String?
    let reviewer_ids: String?
}

struct CreateMRResponseData: Decodable {
    let web_url: String
}
