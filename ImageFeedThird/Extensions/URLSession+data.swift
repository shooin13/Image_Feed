import Foundation

enum NetworkError: Error {
  case httpStatusCode(Int)
  case urlRequestError(Error)
  case urlSessionError
}

extension URLSession {
  func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
    
    let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
      DispatchQueue.main.async {
        completion(result)
      }
    }
    
    let task = dataTask(with: request, completionHandler: { data, response, error in
      if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
        if 200 ..< 300 ~= statusCode {
          fulfillCompletionOnTheMainThread(.success(data))
        } else {
          print("[dataTask]: NetworkError - HTTP статус код \(statusCode), Request: \(request)")
          fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
        }
      } else if let error = error {
        print("[dataTask]: NetworkError - Ошибка URL запроса \(error.localizedDescription), Request: \(request)")
        fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
      } else {
        print("[dataTask]: NetworkError - Ошибка URL сессии, Request: \(request)")
        fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
      }
    })
    
    task.resume()
    return task
  }
  
  func objectTask<T: Decodable>(
    for request: URLRequest,
    completion: @escaping (Result<T, Error>) -> Void
  ) -> URLSessionTask {
    let decoder = JSONDecoder()
    l
    let task = data(for: request) { (result: Result<Data, Error>) in
      switch result {
      case .success(let data):
        do {
          let decodedObject = try decoder.decode(T.self, from: data)
          DispatchQueue.main.async {
            completion(.success(decodedObject))
          }
        } catch {
          print("[objectTask]: Ошибка декодирования \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? ""), Request: \(request)")
          DispatchQueue.main.async {
            completion(.failure(NetworkError.urlSessionError))
          }
        }
        
      case .failure(let error):
        print("[objectTask]: Ошибка - \(error.localizedDescription), Request: \(request)")
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      }
    }
    return task
  }
}
