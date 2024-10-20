import Foundation

// MARK: - ProfileResult

struct ProfileResult: Decodable {
    let id: String
    let username: String
    let first_name: String
    let last_name: String
    let bio: String?
}
