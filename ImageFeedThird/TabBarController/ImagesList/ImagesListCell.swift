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
    label.alpha = 0 // По умолчанию невидим
    return label
  }()
  
  let cellButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
    return button
  }()
  
  private let gradientLayer: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
    gradient.locations = [0.0, 1.0]
    gradient.opacity = 0 // По умолчанию невидим
    return gradient
  }()
  
  // MARK: - Initializer
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
    setupConstraints()
    gradientLayer.opacity = 1
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = CGRect(
      x: 0,
      y: contentView.bounds.height - 50,
      width: contentView.bounds.width,
      height: 50
    )
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    gradientLayer.opacity = 0
    cellLabel.alpha = 0
  }
  
  // MARK: - Setup Methods
  private func setupViews() {
    contentView.addSubview(cellImage)
    cellImage.layer.addSublayer(gradientLayer)
    contentView.addSubview(cellLabel)
    contentView.addSubview(cellButton)
    
    backgroundColor = UIColor(named: "YPBlack")
    selectionStyle = .none
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
  
  // MARK: - Methods to update UI
  func setIsLiked(_ isLiked: Bool) {
    let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
    cellButton.setImage(likeImage, for: .normal)
  }
  
  func showGradientAndLabel() {
    UIView.animate(withDuration: 0.3) {
      self.gradientLayer.opacity = 1
      self.cellLabel.alpha = 1
    }
  }
  
  // MARK: - Actions
  @objc private func likeButtonClicked() {
    delegate?.imageListCellDidTapLike(self)
  }
}

// MARK: - Delegate Protocol

protocol ImagesListCellDelegate: AnyObject {
  func imageListCellDidTapLike(_ cell: ImagesListCell)
}
