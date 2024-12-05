import Foundation

// MARK: - ImagesListHelperProtocol

protocol ImagesListHelperProtocol {
  func fetchPhotosRequest(page: Int) -> URLRequest?
  func likePhotoRequest(photoId: String, isLike: Bool) -> URLRequest?
}

// MARK: - ImagesListHelper

final class ImagesListHelper: ImagesListHelperProtocol {
  private let configuration: ImagesListConfiguration
  
  init(configuration: ImagesListConfiguration = .standard) {
    self.configuration = configuration
  }
  
  func fetchPhotosRequest(page: Int) -> URLRequest? {
    guard let accessToken = configuration.accessToken else {
      print("Ошибка: токен доступа отсутствует")
      return nil
    }
    var components = URLComponents(url: configuration.baseURL.appendingPathComponent("photos"), resolvingAgainstBaseURL: false)
    components?.queryItems = [
      URLQueryItem(name: "page", value: "\(page)"),
      URLQueryItem(name: "per_page", value: "10")
    ]
    guard let url = components?.url else { return nil }
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    return request
  }
  
  func likePhotoRequest(photoId: String, isLike: Bool) -> URLRequest? {
    guard let accessToken = configuration.accessToken else {
      print("Ошибка: токен доступа отсутствует")
      return nil
    }
    let endpoint = "photos/\(photoId)/like"
    guard let url = URL(string: endpoint, relativeTo: configuration.baseURL) else { return nil }
    
    var request = URLRequest(url: url)
    request.httpMethod = isLike ? "POST" : "DELETE"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    return request
  }
}
