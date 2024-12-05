import ImageFeedThird
import Foundation

// MARK: - WebViewPresenterSpy

final class WebViewPresenterSpy: WebViewPresenterProtocol {
  // MARK: - Properties
  
  var viewDidLoadCalled: Bool = false
  var view: WebViewViewControllerProtocol?
  
  // MARK: - WebViewPresenterProtocol Methods
  
  func viewDidLoad() {
    viewDidLoadCalled = true
  }
  
  func didUpdateProgressValue(_ newValue: Double) {
  }
  
  func code(from url: URL) -> String? {
    return nil
  }
}
