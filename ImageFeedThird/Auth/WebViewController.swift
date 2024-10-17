import UIKit
import WebKit

// MARK: - WebViewViewController

final class WebViewViewController: UIViewController {
  
  // MARK: - Properties
  
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
  
  private lazy var progressView: UIProgressView = {
    let progressView = UIProgressView()
    progressView.translatesAutoresizingMaskIntoConstraints = false
    progressView.tintColor = UIColor(named: "YPBlack")
    return progressView
  }()
  
  private enum WebViewConstats {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
  }
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
    view.backgroundColor = .white
    addViews()
    addConstraints()
    loadAuthView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(false)
    webView.addObserver(
      self,
      forKeyPath: #keyPath(WKWebView.estimatedProgress),
      options: .new,
      context: nil
    )
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(false)
    webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
  }
  
  // MARK: - KVO Observer
  
  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    if keyPath == #keyPath(WKWebView.estimatedProgress) {
      updateProgress()
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
  
  // MARK: - Loading the Authorization View
  
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
  
  // MARK: - UI Setup
  
  private func addViews() {
    view.addSubview(webView)
    view.addSubview(backButton)
    view.addSubview(progressView)
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
      backButton.heightAnchor.constraint(equalToConstant: 44),
      
      progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
      progressView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
    ])
  }
  
  private func updateProgress() {
    progressView.progress = Float(webView.estimatedProgress)
    progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
  }
  
  // MARK: - Actions
  
  @objc private func backButtonTapped() {
    delegate?.webViewViewControllerDidCancel(self)
  }
  
  // MARK: - Navigation Handling
  
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

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView,
               decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
    
    print("ITS LIT", navigationAction.request.url)
    
    if let code = code(from: navigationAction) {
      print("nav stopped")
      decisionHandler(.cancel)
      delegate?.webViewViewController(self, didAuthenticateWithCode: code)
    } else {
      print("nav allowed")
      decisionHandler(.allow)
    }
  }
}

// MARK: - WebViewViewControllerDelegate Protocol

protocol WebViewViewControllerDelegate: AnyObject {
  func webViewViewController(_ viewController: WebViewViewController, didAuthenticateWithCode code: String)
  
  func webViewViewControllerDidCancel(_ viewController: WebViewViewController)
}
