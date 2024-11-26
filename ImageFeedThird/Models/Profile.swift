import Foundation

// MARK: - Profile

struct Profile: Decodable {
  let username: String
  let name: String
  let loginName: String
  let bio: String?
}
