import UIKit
import Kingfisher

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {
  
  //MARK: - Properties
  
  private var profile = ProfileService.shared.profile
  
  // MARK: - UI Elements
  
  private lazy var profileImageView: UIImageView = {
    let image = UIImageView()
    image.image = UIImage(named: "Placeholder")
    image.translatesAutoresizingMaskIntoConstraints = false
    image.layer.cornerRadius = image.frame.width / 2
    image.layer.masksToBounds = true
    return image
  }()
  
  private lazy var profileName: UILabel = {
    let label = UILabel()
    label.text = profile?.name
    label.font = UIFont.boldSystemFont(ofSize: 23)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var profileNick: UILabel = {
    let label = UILabel()
    label.text = profile?.loginName
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var profileDescription: UILabel = {
    let label = UILabel()
    label.text = profile?.bio
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = .white
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
    updateAvatar()
    updateProfileUI()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
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
  
  private func updateAvatar() {
    guard let profileImageURL = ProfileImageService.shared.avatarURL,
          let url = URL(string: profileImageURL) else {
      print("Неверный URL для аватара.")
      return
    }
    
    profileImageView.kf.indicatorType = .activity
    
    profileImageView.kf.setImage(
      with: url,
      placeholder: UIImage(named: "Placeholder"),
      options: [
        .targetCache(Constants.avatarImageCache),
        .transition(.fade(0.3))
      ]
    ) { result in
      switch result {
      case .success(let value):
        print("Аватар обновлен: \(value.image)")
      case .failure(let error):
        print("Ошибка при обновлении аватара: \(error.localizedDescription)")
      }
    }
  }
  
  private func updateProfileUI() {
    guard let profile = ProfileService.shared.profile else {
      print("Не удалось загрузить профиль.")
      return
    }
    profileName.text = profile.name
    profileNick.text = profile.loginName
    profileDescription.text = profile.bio
    print("Интерфейс профиля обновлен")
  }
  
  //MARK: - Actions
  
  @objc private func logoutButtonTapped() {
    print("logout tapped")
  }
}
