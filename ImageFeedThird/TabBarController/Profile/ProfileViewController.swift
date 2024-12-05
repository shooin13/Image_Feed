import UIKit

// MARK: - ProfileViewProtocol

protocol ProfileViewProtocol: AnyObject {
  func displayProfile(name: String?, loginName: String?, bio: String?, avatarURL: String?)
  func displayLogoutConfirmation()
  func navigateToSplashScreen()
  func showError(_ message: String)
}

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController, ProfileViewProtocol {
  // MARK: - Properties
  
  private var presenter: ProfilePresenterProtocol!
  private var gradientLayers = [UIView: CAGradientLayer]()
  
  // MARK: - UI Elements
  
  private lazy var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "Placeholder")
    imageView.layer.cornerRadius = 35
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 23)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.accessibilityIdentifier = "profile name label"
    return label
  }()
  
  private lazy var loginNameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 13)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.accessibilityIdentifier = "profile username label"
    return label
  }()
  
  private lazy var bioLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 13)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var logoutButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "LogOutButton"), for: .normal)
    button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.accessibilityIdentifier = "logout button"
    return button
  }()
  
  // MARK: - Initializer
  
  init(presenter: ProfilePresenterProtocol) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupGradients()
    presenter.onViewDidLoad()
  }
  
  // MARK: - Setup UI
  
  private func setupUI() {
    view.backgroundColor = UIColor(named: "YPBlack")
    view.addSubview(profileImageView)
    view.addSubview(nameLabel)
    view.addSubview(loginNameLabel)
    view.addSubview(bioLabel)
    view.addSubview(logoutButton)
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      profileImageView.widthAnchor.constraint(equalToConstant: 70),
      profileImageView.heightAnchor.constraint(equalToConstant: 70),
      
      nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
      nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
      
      loginNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
      loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
      
      bioLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
      bioLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
      bioLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
      
      logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
    ])
  }
  
  // MARK: - Gradients
  
  private func setupGradients() {
    let viewsWithGradients: [UIView] = [profileImageView, nameLabel, loginNameLabel, bioLabel]
    
    for view in viewsWithGradients {
      let gradient = createGradientLayer(for: view)
      view.layer.addSublayer(gradient)
      gradientLayers[view] = gradient
    }
  }
  
  private func createGradientLayer(for view: UIView) -> CAGradientLayer {
    let gradient = CAGradientLayer()
    gradient.colors = [
      UIColor.lightGray.cgColor,
      UIColor.darkGray.cgColor
    ]
    gradient.startPoint = CGPoint(x: 0, y: 0.5)
    gradient.endPoint = CGPoint(x: 1, y: 0.5)
    gradient.frame = view.bounds
    return gradient
  }
  
  private func removeGradients() {
    gradientLayers.values.forEach { $0.removeFromSuperlayer() }
    gradientLayers.removeAll()
    UIView.animate(withDuration: 0.3) {
      self.nameLabel.textColor = .white
      self.loginNameLabel.textColor = .lightGray
      self.bioLabel.textColor = .white
    }
  }
  
  // MARK: - ProfileViewProtocol Methods
  
  func displayProfile(name: String?, loginName: String?, bio: String?, avatarURL: String?) {
    nameLabel.text = name
    loginNameLabel.text = loginName
    bioLabel.text = bio
    
    if let avatarURL = avatarURL, let url = URL(string: avatarURL) {
      profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"))
    }
    removeGradients()
  }
  
  func displayLogoutConfirmation() {
    let alert = UIAlertController(
      title: "Пока, пока!",
      message: "Уверены что хотите выйти?",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
    alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
      self?.presenter.confirmLogout()
    })
    present(alert, animated: true)
  }
  
  func navigateToSplashScreen() {
    let splashViewController = SplashViewController()
    UIApplication.shared.windows.first?.rootViewController = splashViewController
  }
  
  func showError(_ message: String) {
    let alert = UIAlertController(
      title: "Ошибка",
      message: message,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "ОК", style: .default))
    present(alert, animated: true)
  }
  
  // MARK: - Actions
  
  @objc private func logoutButtonTapped() {
    presenter.onLogoutButtonTapped()
  }
  
  // MARK: - Tests
  
  func simulateLogoutButtonTap() {
    logoutButton.sendActions(for: .touchUpInside)
  }
}
