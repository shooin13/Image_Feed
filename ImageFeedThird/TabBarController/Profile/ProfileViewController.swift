import UIKit
import Kingfisher

protocol ProfileViewProtocol: AnyObject {
  func displayProfile(name: String?, loginName: String?, bio: String?, avatarURL: String?)
  func displayLogoutConfirmation()
  func navigateToSplashScreen()
  func showError(_ message: String)
}

final class ProfileViewController: UIViewController, ProfileViewProtocol {
  
  // MARK: - Properties
  
  private var presenter: ProfilePresenterProtocol!
  private var gradientLayers = [UIView: CAGradientLayer]()
  
  // MARK: - UI Elements
  
  private lazy var profileImageView: UIImageView = {
    let image = UIImageView()
    image.image = UIImage(named: "Placeholder")
    image.translatesAutoresizingMaskIntoConstraints = false
    image.layer.cornerRadius = 35
    image.layer.masksToBounds = true
    return image
  }()
  
  private lazy var profileName: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 23)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var profileNick: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 13)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var profileDescription: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 13)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var logoutButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "LogOutButton"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
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
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addViews()
    setupConstraints()
    setupGradients()
    presenter.onViewDidLoad()
  }
  
  // MARK: - ProfileViewProtocol
  
  func displayProfile(name: String?, loginName: String?, bio: String?, avatarURL: String?) {
    if let name = name { profileName.text = name }
    if let loginName = loginName { profileNick.text = loginName }
    if let bio = bio { profileDescription.text = bio }
    if let avatarURL = avatarURL, let url = URL(string: avatarURL) {
      profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"))
    }
    removeGradients()
  }
  
  func displayLogoutConfirmation() {
    let alert = UIAlertController(
      title: "Пока, пока!",
      message: "Уверены, что хотите выйти?",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
    alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
      guard let self = self else { return }
      if let presenter = self.presenter as? ProfilePresenter {
        presenter.confirmLogout()
      }
    })
    present(alert, animated: true)
  }
  
  func navigateToSplashScreen() {
    let splashViewController = SplashViewController()
    UIApplication.shared.windows.first?.rootViewController = splashViewController
  }
  
  func showError(_ message: String) {
    print("Ошибка: \(message)")
  }
  
  // MARK: - Gradients
  
  private func setupGradients() {
    let viewsWithGradients: [UIView] = [profileImageView, profileName, profileNick, profileDescription]
    
    for view in viewsWithGradients {
      let gradient = createGradientLayer(for: view)
      view.layer.addSublayer(gradient)
      gradientLayers[view] = gradient
    }
  }
  
  private func createGradientLayer(for view: UIView) -> CAGradientLayer {
    let gradient = CAGradientLayer()
    gradient.colors = [
      UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
      UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
      UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
    ]
    gradient.locations = [0, 0.5, 1]
    gradient.startPoint = CGPoint(x: 0, y: 0.5)
    gradient.endPoint = CGPoint(x: 1, y: 0.5)
    gradient.cornerRadius = 9
    gradient.masksToBounds = true
    return gradient
  }
  
  private func removeGradients() {
    gradientLayers.values.forEach { $0.removeFromSuperlayer() }
    gradientLayers.removeAll()
    UIView.animate(withDuration: 0.3) {
      self.profileName.textColor = .white
      self.profileNick.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
      self.profileDescription.textColor = .white
    }
  }
  
  // MARK: - Actions
  
  @objc private func logoutButtonTapped() {
    presenter.onLogoutButtonTapped()
  }
  
  // MARK: - Constraints and Views Setup
  
  private func addViews() {
    view.backgroundColor = UIColor(named: "YPBlack")
    view.addSubview(profileImageView)
    view.addSubview(profileName)
    view.addSubview(profileNick)
    view.addSubview(logoutButton)
    view.addSubview(profileDescription)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      profileImageView.widthAnchor.constraint(equalToConstant: 70),
      profileImageView.heightAnchor.constraint(equalToConstant: 70),
      
      profileName.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
      profileName.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
      
      profileNick.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
      profileNick.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 8),
      
      profileDescription.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
      profileDescription.topAnchor.constraint(equalTo: profileNick.bottomAnchor, constant: 8),
      
      logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
    ])
  }
}
