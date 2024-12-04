import WebKit

// MARK: - WebViewPresenterProtocol

public protocol WebViewPresenterProtocol {
  var view: WebViewViewControllerProtocol? { get set }
  func loadAuthView()
  func code(from navigationAction: WKNavigationAction) -> String?
}

// MARK: - WebViewPresenter

final class WebViewPresenter: WebViewPresenterProtocol {
  
  weak var view: WebViewViewControllerProtocol?
  
  private let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
  
  func loadAuthView() {
    guard var urlComponents = URLComponents(string: unsplashAuthorizeURLString) else { return }
    urlComponents.queryItems = [
      URLQueryItem(name: "client_id", value: Constants.accessKey),
      URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "scope", value: Constants.accessScope)
    ]
    guard let url = urlComponents.url else { return }
    let request = URLRequest(url: url)
    view?.load(request: request)
  }
  
  func code(from navigationAction: WKNavigationAction) -> String? {
    if
      let url = navigationAction.request.url,
      let urlComponents = URLComponents(string: url.absoluteString),
      urlComponents.path == "/oauth/authorize/native",
      let queryItems = urlComponents.queryItems,
      let code = queryItems.first(where: { $0.name == "code" })?.value
    {
      return code
    }
    return nil
  }
}
