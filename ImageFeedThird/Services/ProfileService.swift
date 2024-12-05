import Foundation

//MARK: - ProfileServiceError
enum ProfileServiceError: Error {
  case invalidRequest
  case requestInProgress
}


final class ProfileService {
  // MARK: - Singleton
  static let shared = ProfileService()
  
  // MARK: - Properties
  private(set) var profile: Profile?
  private let profileHelper: ProfileHelperProtocol
  private let urlSession: URLSession = .shared
  
  // MARK: - Initializer
  private init(profileHelper: ProfileHelperProtocol = ProfileHelper()) {
    self.profileHelper = profileHelper
  }
  
  // MARK: - Fetch Profile
  func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
    guard let request = profileHelper.fetchProfileRequest() else {
      completion(.failure(ProfileServiceError.invalidRequest))
      return
    }
    
    let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
      switch result {
      case .success(let profileResult):
        let profile = Profile(
          username: profileResult.username,
          name: profileResult.firstName + (profileResult.lastName ?? ""),
          loginName: "@\(profileResult.username)",
          bio: profileResult.bio
        )
        self.profile = profile // Сохраняем профиль
        completion(.success(profile))
      case .failure(let error):
        completion(.failure(error))
      }
    }
    task.resume()
  }
  
  // MARK: - Reset Profile
  func resetProfile() {
    profile = nil
  }
}
