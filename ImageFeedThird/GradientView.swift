import UIKit

final class GradientView: UIView {
  override class var layerClass: AnyClass {
    return CAGradientLayer.classForCoder()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureGradientLayer()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureGradientLayer()
  }

  private func configureGradientLayer() {
    let gradientLayer = layer as! CAGradientLayer
    gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
    gradientLayer.opacity = 0.5
    
    layer.cornerRadius = 16
    layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    layer.masksToBounds = true
  }
}
