import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
  var presenter: WebViewPresenterProtocol? { get set }
  func load(request: URLRequest)
  func setProgressValue(_ newValue: Float)
  func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
  var presenter: WebViewPresenterProtocol?
  weak var delegate: WebViewViewControllerDelegate?
  
  private lazy var webView: WKWebView = {
    let webView = WKWebView()
    webView.backgroundColor = .white
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.accessibilityIdentifier = "UnsplashWebView"
    return webView
  }()
  
  private lazy var backButton: UIButton = {
    let button = UIButton()
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
  
  private var estimatedProgressObservation: NSKeyValueObservation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
    view.backgroundColor = .white
    addViews()
    addConstraints()
    presenter?.viewDidLoad()
    setupProgressObservation()
  }
  
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
  
  private func setupProgressObservation() {
    estimatedProgressObservation = webView.observe(
      \.estimatedProgress,
       options: [],
       changeHandler: { [weak self] _, _ in
         self?.presenter?.didUpdateProgressValue(self?.webView.estimatedProgress ?? 0.0)
       }
    )
  }
  
  func load(request: URLRequest) {
    webView.load(request)
  }
  
  func setProgressValue(_ newValue: Float) {
    progressView.progress = newValue
  }
  
  func setProgressHidden(_ isHidden: Bool) {
    progressView.isHidden = isHidden
  }
  
  @objc private func backButtonTapped() {
    delegate?.webViewViewControllerDidCancel(self)
  }
}

extension WebViewViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView,
               decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if let code = presenter?.code(from: navigationAction.request.url ?? URL(fileURLWithPath: "")) {
      decisionHandler(.cancel)
      delegate?.webViewViewController(self, didAuthenticateWithCode: code)
    } else {
      decisionHandler(.allow)
    }
  }
}


protocol WebViewViewControllerDelegate: AnyObject {
  func webViewViewController(_ viewController: WebViewViewController, didAuthenticateWithCode code: String)
  func webViewViewControllerDidCancel(_ viewController: WebViewViewController)
}
