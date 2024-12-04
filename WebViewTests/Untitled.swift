import ImageFeedThird
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
  var presenter: WebViewPresenterProtocol?
  var loadRequestCalled = false
  var lastRequest: URLRequest?
  
  func load(request: URLRequest) {
    loadRequestCalled = true
    lastRequest = request
  }
  
  func setProgressValue(_ newValue: Float) {}
  func setProgressHidden(_ isHidden: Bool) {}
}

