import UIKit

// MARK: - TabBarController

final class TabBarController: UITabBarController {
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewControllers()
    setupTabBarAppearance()
  }
  
  // MARK: - Setup Methods
  
  private func setupViewControllers() {
    let imagesListViewController = ImagesListViewController()
    let imagesListPresenter = ImagesListPresenter(view: imagesListViewController)
    imagesListViewController.presenter = imagesListPresenter
    imagesListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ImagesTab"), selectedImage: nil)
    
    let profileViewController = createProfileViewController()
    profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ProfileTab"), selectedImage: nil)
    
    self.viewControllers = [imagesListViewController, profileViewController]
  }
  
  private func createProfileViewController() -> ProfileViewController {
    let placeholderView = PlaceholderProfileView()
    
    let presenter = ProfilePresenter(view: placeholderView)
    
    let profileViewController = ProfileViewController(presenter: presenter)
    
    presenter.view = profileViewController
    
    return profileViewController
  }
  
  // MARK: - UI Setup
  
  private func setupTabBarAppearance() {
    tabBar.barTintColor = UIColor(named: "YPBlack")
  }
}

// MARK: - PlaceholderProfileView

final class PlaceholderProfileView: ProfileViewProtocol {
  func displayProfile(name: String?, loginName: String?, bio: String?, avatarURL: String?) {}
  func displayLogoutConfirmation() {}
  func navigateToSplashScreen() {}
  func showError(_ message: String) {}
}
