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
    
    // Создаем ProfileViewController с Presenter
    let profileViewController = createProfileViewController()
    profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ProfileTab"), selectedImage: nil)
    
    self.viewControllers = [imagesListViewController, profileViewController]
  }
  
  private func createProfileViewController() -> ProfileViewController {
    // Создаем пустой экземпляр ProfileViewController
    let placeholderView = PlaceholderProfileView()
    
    // Создаем Presenter с временной View
    let presenter = ProfilePresenter(view: placeholderView)
    
    // Инициализируем реальный ProfileViewController
    let profileViewController = ProfileViewController(presenter: presenter)
    
    // Назначаем реальную View для Presenter
    presenter.view = profileViewController
    
    return profileViewController
  }
  
  // MARK: - UI Setup
  
  private func setupTabBarAppearance() {
    tabBar.barTintColor = UIColor(named: "YPBlack")
  }
}

// MARK: - PlaceholderProfileView

/// Временная заглушка для View, которая реализует протокол ProfileViewProtocol.
final class PlaceholderProfileView: ProfileViewProtocol {
  func displayProfile(name: String?, loginName: String?, bio: String?, avatarURL: String?) {}
  func displayLogoutConfirmation() {}
  func navigateToSplashScreen() {}
  func showError(_ message: String) {}
}
