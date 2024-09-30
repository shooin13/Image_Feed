import UIKit

final class AuthViewController: UIViewController {
  

  
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
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "YPBlack")
    addViews()
    setupConstraints()
  }
  
  
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
  
  @objc private func loginButtonTapped() {
    let secondVC = WebViewViewController()
        secondVC.delegate = self // Устанавливаем делегатом
        secondVC.modalPresentationStyle = .fullScreen
        present(secondVC, animated: true)
  }
  
}

extension AuthViewController: WebViewViewControllerDelegate {
  func webViewViewController(_ viewController: WebViewViewController, didAuthenticateWithCode code: String) {
      
  }
  
  func webViewViewControllerDidCancel(_ viewController: WebViewViewController) {
    print("authVC cancelled")
    viewController.dismiss(animated: true)
  }
  
  
}


protocol WebViewViewControllerDelegate: AnyObject {
  func webViewViewController(_ viewController: WebViewViewController, didAuthenticateWithCode code: String)
  
  func webViewViewControllerDidCancel(_ viewController: WebViewViewController)
}
