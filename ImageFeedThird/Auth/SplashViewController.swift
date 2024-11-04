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
    print("Splash VC loaded")
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
        print("Profile fetched: \(profile)")
        
        ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { result in
          switch result {
          case .success(let imageURL):
            print("Avatar URL: \(imageURL)")
          case .failure(let error):
            print("Failed to fetch avatar URL: \(error)")
          }
        }
        self.switchToTabBarViewController()
        
      case .failure(let error):
        print("Failed to fetch profile: \(error)")
        self.presentErrorAlert(message: "Failed to load profile")
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
    self.present(notAuthorizedUserVC, animated: true)
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
        return
      }
      self.fetchProfile(token: token)
    }
  }
}
