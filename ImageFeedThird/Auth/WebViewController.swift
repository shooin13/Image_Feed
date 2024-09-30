import UIKit
import WebKit

final class WebViewViewController: UIViewController {
  
  weak var delegate: WebViewViewControllerDelegate?
  
  private lazy var webView: WKWebView = {
    let webView = WKWebView()
    webView.backgroundColor = .white
    webView.translatesAutoresizingMaskIntoConstraints = false
    return webView
  }()
  
  private lazy var backButton: UIButton = {
    let button = UIButton()
    button.setTitle("", for: .normal)
    button.setImage(UIImage(named: "BackButtonDark"), for: .normal)
    button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private enum WebViewConstats {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addViews()
    addConstraints()
    loadAuthView()
  }
  
  private func addConstraints() {
    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
      backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      backButton.widthAnchor.constraint(equalToConstant: 44),
      backButton.heightAnchor.constraint(equalToConstant: 44)
    ])
  }
  
  private func addViews() {
    view.addSubview(webView)
    view.addSubview(backButton)
  }
  
  @objc private func backButtonTapped() {
    delegate?.webViewViewControllerDidCancel(self)
  }
  
  private func loadAuthView() {
    guard var urlComponents = URLComponents(string: WebViewConstats.unsplashAuthorizeURLString) else { return }
    urlComponents.queryItems = [
      URLQueryItem(name: "client_id", value: Constants.accessKey),
      URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "scope", value: Constants.accessScope)
    ]
    
    guard let url = urlComponents.url else { return }
    
    let request = URLRequest(url: url)
    webView.load(request)
  }
  
  
}

extension WebViewViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
    if let code = code(from: navigationAction) {
      decisionHandler(.cancel)
    } else {
      decisionHandler(.allow)
    }
  }
  
  private func code(from navigationAction: WKNavigationAction) -> String? {
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

//extension WebViewViewController: WebViewViewControllerDelegate {
//
//}


