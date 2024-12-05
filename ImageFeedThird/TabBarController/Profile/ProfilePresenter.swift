import Foundation

protocol ProfilePresenterProtocol: AnyObject {
  func onViewDidLoad()
  func onLogoutButtonTapped()
  func confirmLogout()
}


import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
  weak var view: ProfileViewProtocol?
  private let profileService: ProfileService
  private let profileImageService: ProfileImageService
  private let logoutService: ProfileLogoutService
  
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
  
  func onViewDidLoad() {
    profileService.fetchProfile { [weak self] result in
      switch result {
      case .success(let profile):
        self?.view?.displayProfile(
          name: profile.name,
          loginName: profile.loginName,
          bio: profile.bio,
          avatarURL: self?.profileImageService.avatarURL
        )
      case .failure:
        self?.view?.showError("Не удалось загрузить профиль")
      }
    }
  }
  
  func onLogoutButtonTapped() {
    view?.displayLogoutConfirmation()
  }
  
  func confirmLogout() {
    logoutService.logout()
    view?.navigateToSplashScreen()
  }
  
}

