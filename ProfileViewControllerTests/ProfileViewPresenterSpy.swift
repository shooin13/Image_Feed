import Foundation
@testable import ImageFeedThird

final class ProfilePresenterSpy: ProfilePresenterProtocol {
  weak var view: ProfileViewProtocol?
  
  var onViewDidLoadCalled = false
  var onLogoutButtonTappedCalled = false
  var confirmLogoutCalled = false
  
  func onViewDidLoad() {
    onViewDidLoadCalled = true
  }
  
  func onLogoutButtonTapped() {
    onLogoutButtonTappedCalled = true
  }
  
  func confirmLogout() {
    confirmLogoutCalled = true
  }
}
