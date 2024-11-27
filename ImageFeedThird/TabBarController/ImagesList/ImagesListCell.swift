import UIKit

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
  // MARK: - Static Properties
  static let reuseIdentifier = "ImagesListCell"
  
  // MARK: - Delegate
  weak var delegate: ImagesListCellDelegate?
  
  // MARK: - UI Elements
  let cellImage: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 16
    return imageView
  }()
  
  let cellLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    label.textColor = .white
    label.text = ""
    label.isHidden = true
    return label
  }()
  
  let cellButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
    button.isHidden = true
    return button
  }()
  
  private let gradientLayer: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [
      UIColor(white: 0.8, alpha: 1).cgColor,
      UIColor(white: 0.6, alpha: 1).cgColor,
      UIColor(white: 0.4, alpha: 1).cgColor
    ]
    gradient.locations = [0, 0.5, 1]
    gradient.startPoint = CGPoint(x: 0, y: 0.5)
    gradient.endPoint = CGPoint(x: 1, y: 0.5)
    gradient.opacity = 0
    return gradient
  }()
  
  private let bottomGradientLayer: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
    gradient.locations = [0.0, 1.0]
    return gradient
  }()
  
  // MARK: - Initializer
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func layoutSubviews() {
    super.layoutSubviews()
    updateGradients()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    gradientLayer.opacity = 0
    gradientLayer.removeAllAnimations()
    cellLabel.text = ""
  }
  
  // MARK: - Setup Methods
  private func setupViews() {
    contentView.addSubview(cellImage)
    contentView.addSubview(cellLabel)
    contentView.addSubview(cellButton)
    cellImage.layer.addSublayer(gradientLayer)
    cellImage.layer.addSublayer(bottomGradientLayer)
    backgroundColor = UIColor(named: "YPBlack")
    selectionStyle = .none
    // Установим изначальные размеры градиентов
    updateGradients()
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
      cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
      
      cellLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
      cellLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8),
      
      cellButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: -8),
      cellButton.topAnchor.constraint(equalTo: cellImage.topAnchor, constant: 8)
    ])
  }
  
  private func updateGradients() {
    gradientLayer.frame = cellImage.bounds
    bottomGradientLayer.frame = CGRect(
      x: 0,
      y: cellImage.bounds.height - 50,
      width: cellImage.bounds.width,
      height: 50
    )
  }
  
  // MARK: - Gradient Animation Methods
  func showGradientAnimation() {
    gradientLayer.opacity = 1
    let animation = CABasicAnimation(keyPath: "locations")
    animation.fromValue = [0, 0.1, 0.3]
    animation.toValue = [0.7, 0.9, 1]
    animation.duration = 1.5
    animation.repeatCount = .infinity
    gradientLayer.add(animation, forKey: "locationsChange")
  }
  
  func removeGradientAnimation() {
    gradientLayer.opacity = 0
    gradientLayer.removeAllAnimations()
  }
  
  func setImage(with url: URL?) {
    showGradientAnimation()
    updateUIElementsVisibility(isImageLoaded: false)
    
    cellImage.kf.setImage(
      with: url,
      placeholder: UIImage(named: "ImageListCellPlaceholder"),
      options: [.transition(.fade(0.3))]
    ) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success:
        self.removeGradientAnimation()
        self.updateUIElementsVisibility(isImageLoaded: true)
        self.delegate?.imageListCellDidUpdateHeight(self)
      case .failure:
        self.removeGradientAnimation()
        print("Ошибка загрузки изображения")
      }
    }
  }
  
  // MARK: - UI Visibility Methods
  private func updateUIElementsVisibility(isImageLoaded: Bool) {
    cellLabel.isHidden = !isImageLoaded
    cellButton.isHidden = !isImageLoaded
    bottomGradientLayer.opacity = isImageLoaded ? 1 : 0
  }
  
  // MARK: - Methods to update UI
  func setIsLiked(_ isLiked: Bool) {
    let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
    cellButton.setImage(likeImage, for: .normal)
  }
  
  func setLabelText(with text: String?) {
    cellLabel.text = text ?? ""
  }
  
  // MARK: - Actions
  @objc private func likeButtonClicked() {
    delegate?.imageListCellDidTapLike(self)
  }
}

// MARK: - Delegate Protocol

protocol ImagesListCellDelegate: AnyObject {
  func imageListCellDidTapLike(_ cell: ImagesListCell)
  func imageListCellDidUpdateHeight(_ cell: ImagesListCell)
}
