import UIKit

final class SplashViewController: UIViewController {
  
  private let storage = OAuth2TokenStorage()
  
  private func checkIfUserIsAuthorized() {
    if let token = storage.token {
      switchToTabBarViewController()
    } else {
      print("not authorized")
      let notAuthorizedUserVC = AuthViewController()
      notAuthorizedUserVC.modalPresentationStyle = .fullScreen
      self.present(notAuthorizedUserVC, animated: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkIfUserIsAuthorized()
  }
  
  private func switchToTabBarViewController() {
    print("authorized")
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController {
      tabBarController.modalPresentationStyle = .fullScreen
      self.present(tabBarController, animated: true)
    }
  }
  
}
