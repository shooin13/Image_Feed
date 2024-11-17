import UIKit
import ProgressHUD

// MARK: - UIBlockingProgressHUD

final class UIBlockingProgressHUD {
  
  //MARK: - Properties
  
  private static var window: UIWindow? {
    return UIApplication.shared.windows.first
  }
  
  // MARK: - Public Methods
  
  static func show() {
    window?.isUserInteractionEnabled = false
    print("UI заблокирован")
    ProgressHUD.animationType = .circleRotateChase
    ProgressHUD.animate()
  }
  
  static func dismiss() {
    window?.isUserInteractionEnabled = true
    print("UI разблокирован")
    ProgressHUD.dismiss()
  }
  
}
