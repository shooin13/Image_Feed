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
    imagesListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ImagesTab"), selectedImage: nil)
    
    let profileViewController = ProfileViewController()
    profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ProfileTab"), selectedImage: nil)
    
    self.viewControllers = [imagesListViewController, profileViewController]
  }
  
  // MARK: - UI Setup
  
  private func setupTabBarAppearance() {
    tabBar.barTintColor = UIColor(named: "YPBlack")
  }
}
