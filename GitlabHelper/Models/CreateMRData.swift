import Foundation

struct CreateMRRequestData: Encodable {
    let title: String
    let description: String?
    let source_branch: String
    let target_branch: String
    let assignee_id: Int?
    let reviewer_ids: [Int]?
    let remove_source_branch: Bool
}

struct CreateMRResponseData: Decodable {
    let web_url: String
}
