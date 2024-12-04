import UIKit
import WebKit

// MARK: - WebViewViewControllerProtocol

public protocol WebViewViewControllerProtocol: AnyObject {
  var presenter: WebViewPresenterProtocol? { get set }
  func load(request: URLRequest)
}

// MARK: - WebViewViewController

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
  
  // MARK: - Properties
  
  var presenter: WebViewPresenterProtocol?
  weak var delegate: WebViewViewControllerDelegate?
  
  private var estimatedProgressObservation: NSKeyValueObservation?
  
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
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
    view.backgroundColor = .white
    addViews()
    addConstraints()
    presenter?.loadAuthView()
    
    estimatedProgressObservation = webView.observe(
      \.estimatedProgress,
       options: [],
       changeHandler: { [weak self] _, _ in
         guard let self = self else { return }
         self.updateProgress()
       }
    )
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(false)
    estimatedProgressObservation = nil
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
  
  // MARK: - WebViewViewControllerProtocol
  
  func load(request: URLRequest) {
    webView.load(request)
  }
  
  // MARK: - Actions
  
  @objc private func backButtonTapped() {
    delegate?.webViewViewControllerDidCancel(self)
  }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView,
               decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
    
    if let code = presenter?.code(from: navigationAction) {
      decisionHandler(.cancel)
      delegate?.webViewViewController(self, didAuthenticateWithCode: code)
    } else {
      decisionHandler(.allow)
    }
  }
}

// MARK: - WebViewViewControllerDelegate Protocol

protocol WebViewViewControllerDelegate: AnyObject {
  func webViewViewController(_ viewController: WebViewViewController, didAuthenticateWithCode code: String)
  func webViewViewControllerDidCancel(_ viewController: WebViewViewController)
}
