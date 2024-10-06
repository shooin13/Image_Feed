import Foundation


final class OAuth2Service {
  
//  private enum OAuth2ServiceError: Error {
//    case codeError
//  }
  
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
  
  private func fetchOAuthToken(code: String, handler: @escaping (Result<Data, Error>) -> Void) {
    
    guard var request = makeOAuthTokenRequest(code: code) else { return }
    
    //    let task = URLSession.shared.dataTask(with: request) { data, response, error in
    //      
    //      if let error {
    //        handler(.failure(error))
    //        return
    //      }
    //      
    //      if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
    //        handler(.failure(OAuth2ServiceError.codeError))
    //        return
    //      }
    //      guard let data else { return }
    //      handler(.success(data))
    //    }
    
    let task = URLSession.shared.data(for: request) { result in
      switch result {
      case .success(let data):
        do {
          let jsonResponse = try JSONSerialization.jsonObject(with: data)
        } catch {
          print("Error JSONSerialization")
        }
      case .failure(let error):
        switch error {
        case let NetworkError.httpStatusCode(statusCode):
          print("statusCode mistake")
        case let NetworkError.urlRequestError(urlError):
          print("urlRequest mistake")
        case NetworkError.urlSessionError:
          print("urlSession mistake")
        default:
          print("Unknown mistake")
        }
      }
    }
    
    task.resume()
  }
}
