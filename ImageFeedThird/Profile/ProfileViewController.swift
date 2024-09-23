import UIKit

final class ProfileViewController: UIViewController {
  
  private lazy var profileImageView: UIImageView = {
    let image = UIImageView()
    image.image = UIImage(named: "ProfileMockImage")
    image.translatesAutoresizingMaskIntoConstraints = false
    image.layer.cornerRadius = image.frame.width / 2
    image.layer.masksToBounds = true
    return image
  }()
  
  private lazy var profileName: UILabel = {
    let label = UILabel()
    label.text = "Pavel Nikolaev"
    label.font = UIFont.boldSystemFont(ofSize: 23)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var profileNick: UILabel = {
    let label = UILabel()
    label.text = "@the314"
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var profileDescription: UILabel = {
    let label = UILabel()
    label.text = "Hello world!"
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var logoutButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "LogOutButton"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addViews()
    setupConstraints()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
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
  
  private func addViews() {
    view.addSubview(profileImageView)
    view.addSubview(profileName)
    view.addSubview(profileNick)
    view.addSubview(logoutButton)
    view.addSubview(profileDescription)
  }
  
}
