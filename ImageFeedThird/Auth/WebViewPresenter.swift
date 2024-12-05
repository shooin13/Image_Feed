import Foundation

// MARK: - WebViewPresenterProtocol

public protocol WebViewPresenterProtocol {
  var view: WebViewViewControllerProtocol? { get set }
  func viewDidLoad()
  func didUpdateProgressValue(_ newValue: Double)
  func code(from url: URL) -> String?
}

// MARK: - WebViewPresenter

final class WebViewPresenter: WebViewPresenterProtocol {
  // MARK: - Properties
  
  weak var view: WebViewViewControllerProtocol?
  var authHelper: AuthHelperProtocol
  
  // MARK: - Initializer
  
  init(authHelper: AuthHelperProtocol = AuthHelper()) {
    self.authHelper = authHelper
  }
  
  // MARK: - WebViewPresenterProtocol Methods
  
  func viewDidLoad() {
    guard let request = authHelper.authRequest() else { return }
    view?.load(request: request)
    didUpdateProgressValue(0)
  }
  
  func didUpdateProgressValue(_ newValue: Double) {
    let newProgressValue = Float(newValue)
    view?.setProgressValue(newProgressValue)
    
    let shouldHideProgress = abs(newProgressValue - 1.0) <= 0.0001
    view?.setProgressHidden(shouldHideProgress)
  }
  
  func code(from url: URL) -> String? {
    authHelper.code(from: url)
  }
}
