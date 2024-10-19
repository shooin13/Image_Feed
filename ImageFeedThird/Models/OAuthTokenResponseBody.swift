import Foundation

// MARK: - OAuthTokenResponseBody

struct OAuthTokenResponseBody: Decodable {
  let access_token: String
  let token_type: String
  let scope: String
  let created_at: Date
}
