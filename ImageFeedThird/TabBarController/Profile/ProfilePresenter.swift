import Foundation

protocol ProfilePresenterProtocol: AnyObject {
  func onViewDidLoad()
  func onLogoutButtonTapped()
}

final class ProfilePresenter: ProfilePresenterProtocol {
  
  // MARK: - Properties
  weak var view: ProfileViewProtocol?
  private let profileService: ProfileService
  private let profileImageService: ProfileImageService
  private let logoutService: ProfileLogoutService
  
  // MARK: - Initializer
  init(
    view: ProfileViewProtocol,
    profileService: ProfileService = ProfileService.shared,
    profileImageService: ProfileImageService = ProfileImageService.shared,
    logoutService: ProfileLogoutService = ProfileLogoutService.shared
  ) {
    self.view = view
    self.profileService = profileService
    self.profileImageService = profileImageService
    self.logoutService = logoutService
  }
  
  // MARK: - ProfilePresenterProtocol
  
  func onViewDidLoad() {
    loadProfile()
    observeAvatarUpdates()
  }
  
  func onLogoutButtonTapped() {
    view?.displayLogoutConfirmation()
  }
  
  func confirmLogout() {
    logoutService.logout()
    view?.navigateToSplashScreen()
  }
  
  // MARK: - Private Methods
  
  private func loadProfile() {
    guard let profile = profileService.profile else {
      view?.showError("Профиль не найден.")
      return
    }
    
    let avatarURL = profileImageService.avatarURL
    view?.displayProfile(
      name: profile.name,
      loginName: profile.loginName,
      bio: profile.bio,
      avatarURL: avatarURL
    )
  }
  
  private func observeAvatarUpdates() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onAvatarUpdated),
      name: ProfileImageService.didChangeNotification,
      object: nil
    )
  }
  
  @objc private func onAvatarUpdated() {
    guard let avatarURL = profileImageService.avatarURL else { return }
    view?.displayProfile(name: nil, loginName: nil, bio: nil, avatarURL: avatarURL)
  }
}
