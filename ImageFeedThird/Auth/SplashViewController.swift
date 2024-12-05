import UIKit

// MARK: - SplashViewController

final class SplashViewController: UIViewController {
  // MARK: - Properties
  
  private let storage = OAuth2TokenStorage()
  private let profileService = ProfileService.shared
  private let profileImageService = ProfileImageService.shared
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("Экран загрузки загружен")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkIfUserIsAuthorized()
  }
  
  // MARK: - User Authorization
  
  private func checkIfUserIsAuthorized() {
    if let token = storage.token {
      fetchProfile(token: token)
    } else {
      presentNotAuthorizedViewController()
    }
  }
  
  // MARK: - Fetch Profile
  
  private func fetchProfile(token: String) {
    UIBlockingProgressHUD.show()
    
    profileService.fetchProfile { [weak self] result in
      UIBlockingProgressHUD.dismiss()
      
      guard let self = self else { return }
      
      switch result {
      case .success(let profile):
        print("Профиль загружен: \(profile)")
        
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self)
        
        ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { result in
          switch result {
          case .success(let imageURL):
            print("URL аватара: \(imageURL)")
          case .failure(let error):
            print("Не удалось загрузить URL аватара: \(error.localizedDescription)")
          }
        }
        self.switchToTabBarViewController()
        
      case .failure(let error):
        print("Не удалось войти в систему: \(error)")
        self.presentErrorAlert(message: "Не удалось войти в систему")
      }
    }
  }
  
  // MARK: - Navigation
  
  private func switchToTabBarViewController() {
    let tabBarController = TabBarController()
    tabBarController.modalPresentationStyle = .fullScreen
    self.present(tabBarController, animated: true)
  }
  
  private func presentNotAuthorizedViewController() {
    let notAuthorizedUserVC = AuthViewController()
    notAuthorizedUserVC.delegate = self
    notAuthorizedUserVC.modalPresentationStyle = .fullScreen
    DispatchQueue.main.async {
      self.present(notAuthorizedUserVC, animated: true)
    }
  }
  
  private func presentErrorAlert(message: String) {
    let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "ОК", style: .default))
    self.present(alert, animated: true, completion: nil)
  }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
  func didAuthenticate(_ vc: AuthViewController) {
    vc.dismiss(animated: true) {
      guard let token = self.storage.token else {
        print("Токен отсутствует после авторизации")
        return
      }
      self.fetchProfile(token: token)
    }
  }
}
