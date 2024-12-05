import Foundation

// MARK: - ProfileHelperProtocol

protocol ProfileHelperProtocol {
  func fetchProfileRequest() -> URLRequest?
}

// MARK: - ProfileHelper

final class ProfileHelper: ProfileHelperProtocol {
  // MARK: - Properties
  
  private let configuration: AuthConfiguration
  
  // MARK: - Initializer
  
  init(configuration: AuthConfiguration = .standard) {
    self.configuration = configuration
  }
  
  // MARK: - ProfileHelperProtocol Methods
  
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
