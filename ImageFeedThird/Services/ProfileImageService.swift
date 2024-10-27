import Foundation

// MARK: - ProfileImageServiceError

enum ProfileImageServiceError: Error {
  case invalidRequest
  case requestInProgress
}

// MARK: - ProfileImageService

final class ProfileImageService {
  
  static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
  
  // MARK: - Shared Instance
  
  static let shared = ProfileImageService()
  
  // MARK: - Properties
  
  private let urlSession: URLSession = .shared
  private var task: URLSessionTask?
  private var ongoingRequests: [((Result<String, Error>) -> Void)] = []
  
  private(set) var avatarURL: String?
  
  // MARK: - Initializer
  
  private init() {}
  
  // MARK: - Fetch Profile Image URL
  
  func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
    assert(Thread.isMainThread)
    
    if !ongoingRequests.isEmpty {
      ongoingRequests.append(completion)
      return
    } else {
      ongoingRequests = [completion]
    }
    
    guard let request = makeProfileImageRequest(for: username) else {
      completeAllRequests(with: .failure(ProfileImageServiceError.invalidRequest))
      return
    }
    task?.cancel()
    
    let task = urlSession.objectTask(for: request) { (result: Result<UserResult, Error>) in
      DispatchQueue.main.async {
        switch result {
        case .success(let userResult):
          let avatarURL = userResult.profile_image.small
          self.avatarURL = avatarURL
          self.completeAllRequests(with: .success(avatarURL))
          NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": avatarURL])
        case .failure(let error):
          print("Network error: \(error)")
          self.completeAllRequests(with: .failure(error))
        }
      }
    }
    self.task = task
    task.resume()
  }
  
  // MARK: - Make Request
  
  private func makeProfileImageRequest(for username: String) -> URLRequest? {
    guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
      assertionFailure("Failed to create URL")
      return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    guard let accessToken = OAuth2TokenStorage().token else {
      assertionFailure("No access token available")
      return nil
    }
    
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    return request
  }
  
  // MARK: - Helper to complete all requests
  
  private func completeAllRequests(with result: Result<String, Error>) {
    ongoingRequests.forEach { $0(result) }
    ongoingRequests = []
  }
}
