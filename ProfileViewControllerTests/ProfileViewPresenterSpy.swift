@testable import ImageFeedThird
import Foundation

// MARK: - ProfilePresenterSpy

final class ProfilePresenterSpy: ProfilePresenterProtocol {
  // MARK: - Properties
  
  weak var view: ProfileViewProtocol?
  var onViewDidLoadCalled = false
  var onLogoutButtonTappedCalled = false
  var confirmLogoutCalled = false
  
  // MARK: - ProfilePresenterProtocol Methods
  
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
