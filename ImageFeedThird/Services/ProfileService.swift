import Foundation

//MARK: - ProfileServiceError
enum ProfileServiceError: Error {
  case invalidRequest
  case requestInProgress
}


//MARK: - ProfileService

final class ProfileService {
  
  // MARK: - Shared Instance
  
  static let shared = ProfileService()
  
  //MARK: - Properties
  
  private let urlSession: URLSession = .shared
  private var task: URLSessionTask?
  private var ongoingRequests: [((Result<Profile, Error>) -> Void)] = []
  
  //MARK: - Initializer
  
  private init() {}
  
  //MARK: - Fetch Profile
  
  func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
    assert(Thread.isMainThread)
    
    if !ongoingRequests.isEmpty {
      ongoingRequests.append(completion)
      return
    } else {
      ongoingRequests = [completion]
    }
    
    guard let request = makeProfileRequest() else {
      completeAllRequests(with: .failure(ProfileServiceError.invalidRequest))
      return
    }
    task?.cancel()
    
    let task = urlSession.data(for: request) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let data):
          do {
            let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
            let profile = self.convertToProfile(from: profileResult)
            self.completeAllRequests(with: .success(profile))
          } catch {
            print("Error decoding JSON \(error)")
            self.completeAllRequests(with: .failure(error))
          }
        case .failure(let error):
          print("Network error: \(error)")
          self.completeAllRequests(with: .failure(error))
        }
      }
    }
    self.task = task
    task.resume()
  }
  
  
  //MARK: - Make Request
  
  private func makeProfileRequest() -> URLRequest? {
    guard let url = URL(string: "https://api.unsplash.com/me") else {
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
  
  private func completeAllRequests(with result: Result<Profile, Error>) {
    ongoingRequests.forEach { $0(result) }
    ongoingRequests = []
  }
  
  // MARK: - Convert ProfileResult to Profile
  
  private func convertToProfile(from profileResult: ProfileResult) -> Profile {
    let name = "\(profileResult.first_name) \(profileResult.last_name)"
    let loginName = "@\(profileResult.username)"
    
    return Profile(
      username: profileResult.username,
      name: name,
      loginName: loginName,
      bio: profileResult.bio
    )
  }
}
