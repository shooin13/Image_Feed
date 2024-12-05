import Foundation

// MARK: - UrlsResult

struct UrlsResult: Decodable {
  // MARK: - Properties
  
  let raw: String
  let full: String
  let regular: String
  let small: String
  let thumb: String
}
