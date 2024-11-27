import UIKit

// MARK: - AuthServiceError

enum AuthServiceError: Error {
  case invalidRequest
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
      assertionFailure("Не удалось создать URL")
      return nil
    }
    
    let endpoint = "/oauth/token"
    + "?client_id=\(Constants.accessKey)"
    + "&&client_secret=\(Constants.secretKey)"
    + "&&redirect_uri=\(Constants.redirectURI)"
    + "&&code=\(code)"
    + "&&grant_type=authorization_code"
    
    guard let url = URL(string: endpoint, relativeTo: baseURL) else {
      assertionFailure("Не удалось создать конечный URL")
      return nil
    }
    
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
      print("[fetchOAuthToken]: AuthServiceError - Неверный запрос, Code: \(code)")
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
          tokenStorage.token = tokenResponse.accessToken
          self.completeAll(for: code, result: .success(tokenResponse.accessToken))
        case .failure(let error):
          DispatchQueue.main.async {
            let alert = UIAlertController(
              title: "Ошибка авторизации",
              message: "Не удалось получить токен. Попробуйте снова.",
              preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
          }
          print("[fetchOAuthToken]: [NetworkError] Ошибка сети \(error.localizedDescription), Code: \(code)")
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
    if let urlError = error as? URLError {
      print("Ошибка запроса URL: \(urlError)")
    } else if let decodingError = error as? DecodingError {
      print("Ошибка декодирования: \(decodingError.localizedDescription)")
      switch decodingError {
      case .typeMismatch(let type, let context):
        print("Несоответствие типа \(type) в \(context)")
      case .valueNotFound(let value, let context):
        print("Значение \(value) не найдено в \(context)")
      case .keyNotFound(let key, let context):
        print("Ключ \(key) не найден в \(context)")
      case .dataCorrupted(let context):
        print("Данные повреждены: \(context)")
      @unknown default:
        print("Неизвестная ошибка декодирования")
      }
    } else if let httpError = error as? NetworkError {
      switch httpError {
      case .httpStatusCode(let statusCode):
        print("Ошибка HTTP со статусом: \(statusCode)")
      case .urlSessionError:
        print("Ошибка сессии URL")
      default:
        print("Неизвестная ошибка сети")
      }
    } else {
      print("Неизвестная ошибка: \(error)")
    }
  }
}
