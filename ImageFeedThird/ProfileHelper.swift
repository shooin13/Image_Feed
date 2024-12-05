import Foundation

protocol ProfileHelperProtocol {
  func fetchProfileRequest() -> URLRequest?
}

final class ProfileHelper: ProfileHelperProtocol {
  private let configuration: AuthConfiguration
  
  init(configuration: AuthConfiguration = .standard) {
    self.configuration = configuration
  }
  
  func fetchProfileRequest() -> URLRequest? {
    guard let url = URL(string: "\(configuration.defaultBaseURL)/me") else {
      return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    guard let accessToken = OAuth2TokenStorage().token else {
      assertionFailure("Access token is missing")
      return nil
    }
    
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    return request
  }
}
