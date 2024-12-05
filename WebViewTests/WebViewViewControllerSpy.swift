import ImageFeedThird
import Foundation

// MARK: - WebViewViewControllerSpy

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
  // MARK: - Properties
  
  var presenter: WebViewPresenterProtocol?
  var loadRequestCalled = false
  var lastRequest: URLRequest?
  var isProgressHidden = false
  
  // MARK: - WebViewViewControllerProtocol Methods
  
  func load(request: URLRequest) {
    loadRequestCalled = true
    lastRequest = request
  }
  
  func setProgressValue(_ newValue: Float) {
  }
  
  func setProgressHidden(_ isHidden: Bool) {
    isProgressHidden = isHidden
  }
}
