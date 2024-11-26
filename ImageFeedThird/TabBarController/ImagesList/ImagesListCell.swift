import UIKit

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
  static let reuseIdentifier = "ImagesListCell"
  
  // MARK: - UI Elements
  
  let cellImage: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  let cellLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    label.textColor = .white
    label.alpha = 0
    return label
  }()
  
  let cellButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private let gradientLayer: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
    gradient.locations = [0.0, 1.0]
    gradient.opacity = 0
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
  
  // MARK: - Setup Methods
  
  private func setupViews() {
    contentView.addSubview(cellImage)
    cellImage.layer.addSublayer(gradientLayer)
    contentView.addSubview(cellLabel)
    contentView.addSubview(cellButton)
    
    self.backgroundColor = UIColor(named: "YPBlack")
    self.selectionStyle = .none
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    updateGradientFrame()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    gradientLayer.opacity = 0
    cellLabel.alpha = 0
  }
  
  func updateGradientFrame() {
    gradientLayer.frame = CGRect(
      x: 0,
      y: contentView.bounds.height - 50,
      width: contentView.bounds.width,
      height: 50
    )
  }
  
  func showGradientAndLabel() {
    UIView.animate(withDuration: 0.3) {
      self.gradientLayer.opacity = 1
      self.cellLabel.alpha = 1
    }
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
      cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
      
      cellLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
      cellLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      
      cellButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: -8),
      cellButton.topAnchor.constraint(equalTo: cellImage.topAnchor, constant: 8)
    ])
  }
}
