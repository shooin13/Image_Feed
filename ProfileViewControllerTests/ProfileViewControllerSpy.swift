import UIKit
@testable import ImageFeedThird

final class ProfileViewControllerSpy: ProfileViewProtocol {
  var displayProfileCalled = false
  var displayLogoutConfirmationCalled = false
  var navigateToSplashScreenCalled = false
  var showErrorCalled = false
  var displayedProfileData: (name: String?, loginName: String?, bio: String?, avatarURL: String?)?
  
  func displayProfile(name: String?, loginName: String?, bio: String?, avatarURL: String?) {
    displayProfileCalled = true
    displayedProfileData = (name, loginName, bio, avatarURL)
  }
  
  func displayLogoutConfirmation() {
    displayLogoutConfirmationCalled = true
  }
  
  func navigateToSplashScreen() {
    navigateToSplashScreenCalled = true
  }
  
  func showError(_ message: String) {
    showErrorCalled = true
  }
}
