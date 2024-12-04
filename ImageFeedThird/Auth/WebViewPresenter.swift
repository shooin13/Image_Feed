import WebKit

// MARK: - WebViewPresenterProtocol

public protocol WebViewPresenterProtocol {
  var view: WebViewViewControllerProtocol? { get set }
  func viewDidLoad()
  func didUpdateProgressValue(_ newValue: Double)
  func code(from url: URL) -> String?
}

// MARK: - WebViewPresenter

final class WebViewPresenter: WebViewPresenterProtocol {
  
  weak var view: WebViewViewControllerProtocol?
  
  private let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
  
  func viewDidLoad() {
    guard var urlComponents = URLComponents(string: unsplashAuthorizeURLString) else { return }
    urlComponents.queryItems = [
      URLQueryItem(name: "client_id", value: Constants.accessKey),
      URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "scope", value: Constants.accessScope)
    ]
    
    guard let url = urlComponents.url else { return }
    let request = URLRequest(url: url)
    
    didUpdateProgressValue(0)
    view?.load(request: request)
  }
  
  func didUpdateProgressValue(_ newValue: Double) {
    let newProgressValue = Float(newValue)
    view?.setProgressValue(newProgressValue)
    
    let shouldHideProgress = shouldHideProgress(for: newProgressValue)
    view?.setProgressHidden(shouldHideProgress)
  }
  
  func code(from url: URL) -> String? {
    if let urlComponents = URLComponents(string: url.absoluteString),
       urlComponents.path == "/oauth/authorize/native",
       let items = urlComponents.queryItems,
       let codeItem = items.first(where: { $0.name == "code" }) {
      return codeItem.value
    } else {
      return nil
    }
  }
  
  private func shouldHideProgress(for value: Float) -> Bool {
    abs(value - 1.0) <= 0.0001
  }
}