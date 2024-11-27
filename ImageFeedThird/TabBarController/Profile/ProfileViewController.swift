import UIKit
import Kingfisher

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {
  
  // MARK: - Properties
  
  private var profile = ProfileService.shared.profile
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
    label.text = profile?.name
    label.font = UIFont.boldSystemFont(ofSize: 23)
    label.textColor = .clear
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var profileNick: UILabel = {
    let label = UILabel()
    label.text = profile?.loginName
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = .clear
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var profileDescription: UILabel = {
    let label = UILabel()
    label.text = profile?.bio
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = .clear
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
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addViews()
    setupConstraints()
    setupGradients()
    startGradientAnimations()
    updateAvatar()
    updateProfileUI()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateProfileUI),
      name: ProfileImageService.didChangeNotification,
      object: nil
    )
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateGradientFrames()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - UI Setup
  
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
  
  private func addViews() {
    view.backgroundColor = UIColor(named: "YPBlack")
    view.addSubview(profileImageView)
    view.addSubview(profileName)
    view.addSubview(profileNick)
    view.addSubview(logoutButton)
    view.addSubview(profileDescription)
  }
  
  // MARK: - Gradient Setup
  
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
  
  private func updateGradientFrames() {
    for (view, gradient) in gradientLayers {
      gradient.frame = view.bounds
    }
  }
  
  private func startGradientAnimations() {
    for gradient in gradientLayers.values {
      let animation = CABasicAnimation(keyPath: "locations")
      animation.fromValue = [0, 0.1, 0.3]
      animation.toValue = [0.7, 0.9, 1]
      animation.duration = 1.5
      animation.repeatCount = .infinity
      gradient.add(animation, forKey: "locationsChange")
    }
  }
  
  private func removeGradients() {
    gradientLayers.values.forEach { $0.removeFromSuperlayer() }
    gradientLayers.removeAll()
    showProfileContent()
  }
  
  private func showProfileContent() {
    UIView.animate(withDuration: 0.3) {
      self.profileName.textColor = .white
      self.profileNick.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
      self.profileDescription.textColor = .white
    }
  }
  
  // MARK: - Avatar Update
  
  private func updateAvatar() {
    guard let profileImageURL = ProfileImageService.shared.avatarURL,
          let url = URL(string: profileImageURL) else {
      print("Неверный URL для аватара.")
      return
    }
    
    profileImageView.kf.setImage(
      with: url,
      placeholder: UIImage(named: "Placeholder"),
      options: [
        .targetCache(Constants.avatarImageCache),
        .transition(.fade(0.3))
      ]
    ) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success:
        print("Аватар обновлен")
        self.removeGradients()
      case .failure(let error):
        print("Ошибка при обновлении аватара: \(error.localizedDescription)")
      }
    }
  }
  
  @objc private func updateProfileUI() {
    guard let profile = ProfileService.shared.profile else {
      print("Не удалось загрузить профиль.")
      return
    }
    profileName.text = profile.name
    profileNick.text = profile.loginName
    profileDescription.text = profile.bio
    print("Интерфейс профиля обновлен")
  }
  
  // MARK: - Actions
  
  @objc private func logoutButtonTapped() {
    ProfileLogoutService.shared.logout()
    switchToSplashViewController()
  }
  
  private func switchToSplashViewController() {
    let splashViewController = SplashViewController()
    splashViewController.modalPresentationStyle = .fullScreen
    present(splashViewController, animated: true)
  }
}
