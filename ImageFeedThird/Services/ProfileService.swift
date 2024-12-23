import Foundation

//MARK: - ProfileServiceError
enum ProfileServiceError: Error {
  case invalidRequest
  case requestInProgress
}

// MARK: - ProfileService

final class ProfileService {
  
  // MARK: - Shared Instance
  
  static let shared = ProfileService()
  
  //MARK: - Properties
  
  private let urlSession: URLSession = .shared
  private var task: URLSessionTask?
  private var ongoingRequests: [((Result<Profile, Error>) -> Void)] = []
  
  private(set) var profile: Profile?
  
  // MARK: - Initializer
  
  private init() {}
  
  // MARK: - Fetch Profile
  
  func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
    assert(Thread.isMainThread)
    
    if !ongoingRequests.isEmpty {
      ongoingRequests.append(completion)
      return
    } else {
      ongoingRequests = [completion]
    }
    
    guard let request = makeProfileRequest() else {
      print("[fetchProfile]: [ProfileServiceError.invalidRequest] Ошибка создания запроса")
      completeAllRequests(with: .failure(ProfileServiceError.invalidRequest))
      return
    }
    
    task?.cancel()
    
    let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
      DispatchQueue.main.async {
        switch result {
        case .success(let profileResult):
          let profile = self.convertToProfile(from: profileResult)
          self.profile = profile
          self.completeAllRequests(with: .success(profile))
        case .failure(let error):
          if let decodingError = error as? DecodingError {
            print("[fetchProfile]: [DecodingError] Ошибка декодирования \(decodingError.localizedDescription), Request: \(request)")
          } else {
            print("[fetchProfile]: [NetworkError] Ошибка сети \(error.localizedDescription), Request: \(request)")
          }
          self.completeAllRequests(with: .failure(error))
        }
      }
    }
    self.task = task
    task.resume()
  }
  
  // MARK: - Reset Profile
  func resetProfile() {
    profile = nil
  }
  
  // MARK: - Make Request
  
  private func makeProfileRequest() -> URLRequest? {
    guard let url = URL(string: "https://api.unsplash.com/me") else {
      assertionFailure("Не удалось создать URL")
      return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    guard let accessToken = OAuth2TokenStorage().token else {
      assertionFailure("Токен доступа отсутствует")
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
    let lastName = profileResult.lastName ?? ""
    let name = lastName.isEmpty ? profileResult.firstName : "\(profileResult.firstName) \(lastName)"
    let loginName = "@\(profileResult.username)"
    let bio = profileResult.bio ?? ""
    
    return Profile(
      username: profileResult.username,
      name: name,
      loginName: loginName,
      bio: bio
    )
  }
}
