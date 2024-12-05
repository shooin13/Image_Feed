import Foundation

// MARK: - ImagesListConfiguration

struct ImagesListConfiguration {
  let baseURL: URL
  let accessToken: String?
  
  static var standard: ImagesListConfiguration {
    return ImagesListConfiguration(
      baseURL: URL(string: "https://api.unsplash.com/")!,
      accessToken: OAuth2TokenStorage().token
    )
  }
}
