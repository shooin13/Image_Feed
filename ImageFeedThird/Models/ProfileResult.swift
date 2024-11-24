import Foundation

// MARK: - ProfileResult

struct ProfileResult: Decodable {
  let id: String
  let username: String
  let firstName: String
  let lastName: String?
  let bio: String?
  
  private enum CodingKeys: String, CodingKey {
    case id
    case username
    case firstName = "first_name"
    case lastName = "last_name"
    case bio
  }
}
