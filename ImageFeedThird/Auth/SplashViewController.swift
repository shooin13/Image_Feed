import UIKit

// MARK: - SplashViewController

final class SplashViewController: UIViewController {
  
  // MARK: - Properties
  
  private let storage = OAuth2TokenStorage()
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkIfUserIsAuthorized()
  }
  
  // MARK: - User Authorization
  
  private func checkIfUserIsAuthorized() {
    if let token = storage.token {
      switchToTabBarViewController()
    } else {
      presentNotAuthorizedViewController()
    }
  }
  
  private func switchToTabBarViewController() {
    print("authorized")
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController {
      tabBarController.modalPresentationStyle = .fullScreen
      self.present(tabBarController, animated: true)
    }
  }
  
  private func presentNotAuthorizedViewController() {
    print("not authorized")
    let notAuthorizedUserVC = AuthViewController()
    notAuthorizedUserVC.delegate = self
    notAuthorizedUserVC.modalPresentationStyle = .fullScreen
    self.present(notAuthorizedUserVC, animated: true)
  }
  
}

extension SplashViewController: AuthViewControllerDelegate {
  func didAuthenticate(_ vc: AuthViewController) {
    print("authenticated")
    vc.dismiss(animated: true)
    switchToTabBarViewController()
  }
}
