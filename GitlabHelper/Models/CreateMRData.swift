import Foundation

struct CreateMRRequestData: Encodable {
    let title: String
    let source_branch: String
    let target_branch: String
    let assignee_id: Int?
    let reviewer_ids: [Int]?
}

struct CreateMRResponseData: Decodable {
    let web_url: String
}
