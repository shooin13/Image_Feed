import Foundation

// MARK: - ImagesListConfiguration

struct ImagesListConfiguration {
  // MARK: - Properties
  
  let baseURL: URL
  let accessToken: String?
  
  // MARK: - Standard Configuration
  
  static var standard: ImagesListConfiguration {
    return ImagesListConfiguration(
      baseURL: URL(string: "https://api.unsplash.com/")!,
      accessToken: OAuth2TokenStorage().token
    )
  }
}
