import UIKit

// MARK: - GradientView

final class GradientView: UIView {
  override class var layerClass: AnyClass {
    return CAGradientLayer.self
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureGradientLayer()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureGradientLayer()
  }
  
  // MARK: - Gradient Configuration
  
  private func configureGradientLayer() {
    guard let gradientLayer = layer as? CAGradientLayer else { return }
    gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
    gradientLayer.locations = [0.0, 1.0]
    
    layer.cornerRadius = 16
    layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    layer.masksToBounds = true
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    guard let gradientLayer = layer as? CAGradientLayer else { return }
    gradientLayer.frame = bounds
    
    gradientLayer.frame.origin.y = bounds.height - gradientLayer.frame.height
  }
}
