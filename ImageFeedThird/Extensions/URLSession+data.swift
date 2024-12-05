import Foundation

// MARK: - NetworkError

enum NetworkError: Error {
  case httpStatusCode(Int)
  case urlRequestError(Error)
  case urlSessionError
  case decodingError(DecodingError)
}

// MARK: - URLSession Extension

extension URLSession {
  // MARK: - Data Request
  
  func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
    let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
      DispatchQueue.main.async {
        completion(result)
      }
    }
    
    let task = dataTask(with: request) { data, response, error in
      if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
        if 200..<300 ~= statusCode {
          fulfillCompletionOnTheMainThread(.success(data))
        } else {
          print("[dataTask]: [NetworkError] HTTP статус код \(statusCode), Request: \(request)")
          fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
        }
      } else if let error = error {
        print("[dataTask]: [NetworkError.urlRequestError] Ошибка URL запроса \(error.localizedDescription), Request: \(request)")
        fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
      } else {
        print("[dataTask]: [NetworkError.urlSessionError] Ошибка URL сессии, Request: \(request)")
        fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
      }
    }
    
    task.resume()
    return task
  }
  
  // MARK: - Object Task
  
  func objectTask<T: Decodable>(
    for request: URLRequest,
    completion: @escaping (Result<T, Error>) -> Void
  ) -> URLSessionTask {
    let decoder = JSONDecoder()
    let task = data(for: request) { (result: Result<Data, Error>) in
      switch result {
      case .success(let data):
        do {
          let decodedObject = try decoder.decode(T.self, from: data)
          DispatchQueue.main.async {
            completion(.success(decodedObject))
          }
        } catch let decodingError as DecodingError {
          print("[objectTask]: [DecodingError] Ошибка декодирования \(decodingError.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "nil"), Request: \(request)")
          DispatchQueue.main.async {
            completion(.failure(NetworkError.decodingError(decodingError)))
          }
        } catch {
          print("[objectTask]: [NetworkError] Неизвестная ошибка \(error.localizedDescription), Request: \(request)")
          DispatchQueue.main.async {
            completion(.failure(error))
          }
        }
      case .failure(let error):
        print("[objectTask]: [NetworkError] Ошибка сети \(error.localizedDescription), Request: \(request)")
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      }
    }
    return task
  }
}
