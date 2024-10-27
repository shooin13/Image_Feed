import Foundation

// MARK: - AuthServiceError

enum AuthServiceError: Error {
  case invalidRequest
  case requestInProgress
}

// MARK: - OAuth2Service

final class OAuth2Service {
  
  // MARK: - Shared Instance
  
  static let shared = OAuth2Service()
  
  // MARK: - Properties
  
  private let urlSession: URLSession = .shared
  private var task: URLSessionTask?
  private var lastCode: String?
  private var ongoingRequests: [String: [((Result<String, Error>) -> Void)]] = [:]
  
  // MARK: - Initializer
  
  private init() {}
  
  // MARK: - OAuth Token Request
  
  private func makeOAuthTokenRequest(code: String) -> URLRequest? {
    guard let baseURL = URL(string: "https://unsplash.com") else {
      assertionFailure("Failed to create URL")
      return nil
    }
    let url = URL(
      string: "/oauth/token"
      + "?client_id=\(Constants.accessKey)"
      + "&&client_secret=\(Constants.secretKey)"
      + "&&redirect_uri=\(Constants.redirectURI)"
      + "&&code=\(code)"
      + "&&grant_type=authorization_code",
      relativeTo: baseURL
    )!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    return request
  }
  
  // MARK: - Fetch OAuth Token
  
  func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
    assert(Thread.isMainThread)
    
    if let requests = ongoingRequests[code] {
      ongoingRequests[code] = requests + [completion]
      return
    } else {
      ongoingRequests[code] = [completion]
    }
    
    guard let request = makeOAuthTokenRequest(code: code) else {
      completeAll(for: code, result: .failure(AuthServiceError.invalidRequest))
      return
    }
    
    task?.cancel()
    lastCode = code
    
    let task = urlSession.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
      DispatchQueue.main.async {
        switch result {
        case .success(let tokenResponse):
          let tokenStorage = OAuth2TokenStorage()
          tokenStorage.token = tokenResponse.access_token
          self.completeAll(for: code, result: .success(tokenResponse.access_token))
        case .failure(let error):
          self.handleNetworkError(error)
          self.completeAll(for: code, result: .failure(error))
        }
      }
    }
    self.task = task
    task.resume()
  }
  
  // MARK: - Helper to complete all requests
  
  private func completeAll(for code: String, result: Result<String, Error>) {
    if let completions = ongoingRequests[code] {
      completions.forEach { $0(result) }
    }
    ongoingRequests[code] = nil
  }
  
  // MARK: - Error Handling
  
  private func handleNetworkError(_ error: Error) {
    switch error {
    case let NetworkError.httpStatusCode(statusCode):
      print("statusCode mistake \(statusCode)")
    case let NetworkError.urlRequestError(urlError):
      print("urlRequest mistake \(urlError)")
    case NetworkError.urlSessionError:
      print("urlSession mistake")
    default:
      print("Unknown mistake")
    }
  }
}
