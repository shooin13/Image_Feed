import Foundation


final class OAuth2Service {
  
  static let shared = OAuth2Service()
  private init() {}
  
  private func makeOAuthTokenRequest(code: String) -> URLRequest? {
    
    guard let baseURL = URL(string: "https://unsplash.com") else { return nil }
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
  
  func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
    
    guard let request = makeOAuthTokenRequest(code: code) else { return }
    
    let task = URLSession.shared.data(for: request) { result in
      switch result {
        
      case .success(let data):
        do {
          let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
          
          let tokenStorage = OAuth2TokenStorage()
          tokenStorage.token = tokenResponse.access_token
          
          completion(.success(tokenResponse.access_token))
        } catch {
          print("Error decoding JSON \(error)")
          completion(.failure(error))
        }
        
      case .failure(let error):
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
        completion(.failure(error))
      }
    }
    
    task.resume()
  }
}
