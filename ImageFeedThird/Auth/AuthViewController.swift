import UIKit
import ProgressHUD

// MARK: - AuthViewController

final class AuthViewController: UIViewController {
  
  // MARK: - Properties
  
  private let oauth2Service = OAuth2Service.shared
  
  weak var delegate: AuthViewControllerDelegate?
  
  private lazy var loginButton: UIButton = {
    let button = UIButton()
    button.setTitle("Войти", for: .normal)
    button.setTitleColor(UIColor(named: "YPBlack"), for: .normal)
    button.backgroundColor = .white
    button.layer.cornerRadius = 16
    button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    return button
  }()
  
  private lazy var unsplashLogo: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "UnsplashLogo")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "YPBlack")
    addViews()
    setupConstraints()
  }
  
  // MARK: - Setup Views
  
  private func addViews() {
    view.addSubview(loginButton)
    view.addSubview(unsplashLogo)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      loginButton.heightAnchor.constraint(equalToConstant: 48),
      loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
      
      unsplashLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      unsplashLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      unsplashLogo.widthAnchor.constraint(equalToConstant: 60),
      unsplashLogo.heightAnchor.constraint(equalToConstant: 60)
    ])
  }
  
  // MARK: - Actions
  
  @objc private func loginButtonTapped() {
    let secondVC = WebViewViewController()
    secondVC.delegate = self
    secondVC.modalPresentationStyle = .fullScreen
    present(secondVC, animated: true)
  }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
  func webViewViewController(_ viewController: WebViewViewController, didAuthenticateWithCode code: String) {
    
    UIBlockingProgressHUD.show()
    
    oauth2Service.fetchOAuthToken(code: code) { result in
      
      UIBlockingProgressHUD.dismiss()
      
      switch result {
      case .success(let token):
        print("Токен получен \(token)")
        self.delegate?.didAuthenticate(self)
        viewController.dismiss(animated: true) {
          let tabBarController = TabBarController()
          tabBarController.modalPresentationStyle = .fullScreen
          self.present(tabBarController, animated: true)
        }
      case .failure(let error):
        print("Не удалось получить токен: \(error.localizedDescription)")
        let alert = UIAlertController(title: "Ошибка", message: "Не удалось получить токен: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        self.present(alert, animated: true)
      }
    }
  }
  
  
  func webViewViewControllerDidCancel(_ viewController: WebViewViewController) {
    print("Авторизация отменена")
    viewController.dismiss(animated: true)
  }
}

protocol AuthViewControllerDelegate: AnyObject {
  func didAuthenticate(_ vc: AuthViewController)
}
