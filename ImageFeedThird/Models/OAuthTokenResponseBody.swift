import Foundation

// MARK: - OAuthTokenResponseBody

struct OAuthTokenResponseBody: Decodable {
  let accessToken: String
  let tokenType: String
  let scope: String
  let createdAt: Date
  
  private enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case scope
    case createdAt = "created_at"
  }
}
